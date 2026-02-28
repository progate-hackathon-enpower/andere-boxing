use std::env;
use std::net::SocketAddr;
use std::sync::atomic::{AtomicU64, Ordering};

use bytes::Bytes;
use tokio::sync::mpsc;
use tracing::{error, info};
use wtransport::tls::{Certificate, CertificateChain, PrivateKey};
use wtransport::{Endpoint, Identity, ServerConfig};

use crate::broadcast::BroadcastManager;
use crate::connection::ClientConnection;

/// Global client ID counter
static CLIENT_ID_COUNTER: AtomicU64 = AtomicU64::new(0);

/// WebTransport game server
pub struct GameServer {
    endpoint: Endpoint<wtransport::endpoint::endpoint_side::Server>,
    broadcast: BroadcastManager,
    broadcast_tx: mpsc::Sender<Bytes>,
}

impl GameServer {
    /// Load TLS identity from environment variables (CERT and KEY)
    fn load_identity() -> anyhow::Result<Identity> {
        let cert_pem = env::var("CERT")
            .map_err(|_| anyhow::anyhow!("CERT environment variable not set"))?;
        let key_pem = env::var("KEY")
            .map_err(|_| anyhow::anyhow!("KEY environment variable not set"))?;

        // Parse PEM certificate
        let cert_pem_parsed = pem::parse(&cert_pem)
            .map_err(|e| anyhow::anyhow!("Failed to parse certificate PEM: {:?}", e))?;
        let cert = Certificate::from_der(cert_pem_parsed.contents().to_vec())
            .map_err(|e| anyhow::anyhow!("Failed to parse certificate DER: {:?}", e))?;
        let cert_chain = CertificateChain::single(cert);

        // Parse PEM private key
        let key_pem_parsed = pem::parse(&key_pem)
            .map_err(|e| anyhow::anyhow!("Failed to parse private key PEM: {:?}", e))?;
        let private_key = PrivateKey::from_der_pkcs8(key_pem_parsed.contents().to_vec());

        Ok(Identity::new(cert_chain, private_key))
    }

    /// Create a new game server bound to the specified address
    pub async fn new(addr: SocketAddr) -> anyhow::Result<Self> {
        let identity = Self::load_identity()?;

        let config = ServerConfig::builder()
            .with_bind_address(addr)
            .with_identity(identity)
            .build();

        let endpoint = Endpoint::server(config)?;
        let broadcast = BroadcastManager::new();
        let (broadcast_tx, broadcast_rx) = mpsc::channel::<Bytes>(4096);

        // Start the broadcast dispatcher
        broadcast.spawn_dispatcher(broadcast_rx);

        Ok(Self {
            endpoint,
            broadcast,
            broadcast_tx,
        })
    }

    /// Run the server, accepting connections indefinitely
    pub async fn run(&self) -> anyhow::Result<()> {
        info!("WebTransport server listening");

        loop {
            let incoming = self.endpoint.accept().await;
            let broadcast = self.broadcast.clients();
            let broadcast_tx = self.broadcast_tx.clone();
            let id = CLIENT_ID_COUNTER.fetch_add(1, Ordering::Relaxed);

            tokio::spawn(async move {
                if let Err(e) = Self::handle_connection(incoming, broadcast, broadcast_tx, id).await
                {
                    error!("Connection error: {:?}", e);
                }
            });
        }
    }

    /// Handle a single incoming connection
    async fn handle_connection(
        incoming: wtransport::endpoint::IncomingSession,
        clients: std::sync::Arc<dashmap::DashMap<u64, mpsc::Sender<Bytes>>>,
        broadcast_tx: mpsc::Sender<Bytes>,
        client_id: u64,
    ) -> anyhow::Result<()> {
        let session_request = incoming.await?;

        info!(
            "New session from {} to {}",
            session_request.authority(),
            session_request.path()
        );

        let connection = session_request.accept().await?;
        info!("Client {} connected", client_id);

        // Create client connection handler
        let mut client = ClientConnection::new(client_id, connection);

        // Register client for broadcasts
        clients.insert(client_id, client.outgoing_tx());

        // Spawn sender and receiver tasks
        let sender_handle = client.spawn_sender();
        let receiver_handle = client.spawn_receiver(broadcast_tx);

        // Wait for either task to complete (receiver usually finishes first on disconnect)
        tokio::select! {
            _ = receiver_handle => {
                info!("Client {} receiver finished", client_id);
            }
            _ = sender_handle => {
                info!("Client {} sender finished", client_id);
            }
        }

        // Unregister client
        clients.remove(&client_id);
        info!("Client {} removed", client_id);

        Ok(())
    }
}
