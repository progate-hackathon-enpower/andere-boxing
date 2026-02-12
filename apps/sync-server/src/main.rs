use std::net::{Ipv4Addr, SocketAddr};
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;

use bytes::Bytes;
use dashmap::DashMap;
use futures::future::join_all;
use tokio::sync::mpsc;
use tracing::{debug, error, info};
use wtransport::{Connection, Endpoint, Identity, ServerConfig};

mod proto_out;

/// Per-client state with dedicated send channel
struct ClientState {
    connection: Connection,
    tx: mpsc::Sender<Bytes>,
}

/// Thread-safe client registry using lock-free DashMap
type Clients = Arc<DashMap<u64, ClientState>>;

/// Global client ID counter
static CLIENT_ID_COUNTER: AtomicU64 = AtomicU64::new(0);

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt::init();

    let config = ServerConfig::builder()
        .with_bind_address(SocketAddr::new(Ipv4Addr::LOCALHOST.into(), 4433))
        .with_identity(Identity::self_signed(["localhost"]).unwrap())
        .build();

    let server = Endpoint::server(config)?;
    let clients: Clients = Arc::new(DashMap::new());
    let (broadcast_tx, broadcast_rx) = mpsc::channel::<Bytes>(4096);

    // Spawn broadcast dispatcher
    spawn_broadcast_dispatcher(clients.clone(), broadcast_rx);

    info!("WebTransport server listening on https://localhost:4433");

    loop {
        let incoming = server.accept().await;
        let clients = clients.clone();
        let broadcast_tx = broadcast_tx.clone();
        let id = CLIENT_ID_COUNTER.fetch_add(1, Ordering::Relaxed);

        tokio::spawn(async move {
            if let Err(e) = handle_connection(incoming, clients, broadcast_tx, id).await {
                error!("Connection error: {:?}", e);
            }
        });
    }
}

/// Broadcast dispatcher that fans out messages to all client send tasks
fn spawn_broadcast_dispatcher(clients: Clients, mut broadcast_rx: mpsc::Receiver<Bytes>) {
    tokio::spawn(async move {
        while let Some(data) = broadcast_rx.recv().await {
            // Collect all client senders (quick iteration, no blocking)
            let senders: Vec<_> = clients
                .iter()
                .map(|entry| (entry.key().to_owned(), entry.value().tx.clone()))
                .collect();

            // Fan out to all clients in parallel using try_send (non-blocking)
            let send_futures = senders.into_iter().map(|(client_id, tx)| {
                let data = data.clone(); // Bytes clone is cheap (reference count)
                async move {
                    if let Err(e) = tx.try_send(data) {
                        debug!("Client {} send buffer full or disconnected: {:?}", client_id, e);
                    }
                }
            });

            join_all(send_futures).await;
        }
    });
}

/// Per-client send task that handles actual datagram transmission
fn spawn_client_sender(
    client_id: u64,
    connection: Connection,
    mut rx: mpsc::Receiver<Bytes>,
) {
    tokio::spawn(async move {
        while let Some(data) = rx.recv().await {
            if let Err(e) = connection.send_datagram(&data) {
                debug!("Failed to send datagram to client {}: {:?}", client_id, e);
                break;
            }
        }
        debug!("Client {} sender task terminated", client_id);
    });
}

async fn handle_connection(
    incoming: wtransport::endpoint::IncomingSession,
    clients: Clients,
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

    // Create per-client send channel with backpressure
    let (client_tx, client_rx) = mpsc::channel::<Bytes>(256);

    // Spawn dedicated sender task for this client
    spawn_client_sender(client_id, connection.clone(), client_rx);

    // Register client (lock-free insertion)
    clients.insert(
        client_id,
        ClientState {
            connection: connection.clone(),
            tx: client_tx,
        },
    );

    // Receive datagrams and broadcast
    loop {
        match connection.receive_datagram().await {
            Ok(data) => {
                debug!("Client {} sent {} bytes", client_id, data.len());

                // Convert to Bytes for zero-copy sharing
                let bytes = Bytes::copy_from_slice(&data);

                if let Err(e) = broadcast_tx.send(bytes).await {
                    error!("Broadcast channel closed: {:?}", e);
                    break;
                }
            }
            Err(e) => {
                debug!("Client {} disconnected: {:?}", client_id, e);
                break;
            }
        }
    }

    // Remove client (lock-free removal)
    clients.remove(&client_id);

    info!("Client {} removed", client_id);
    Ok(())
}
