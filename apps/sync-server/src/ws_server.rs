use std::env;
use std::net::SocketAddr;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;

use bytes::Bytes;
use futures::StreamExt;
use tokio::net::TcpListener;
use tokio::sync::mpsc;
use tokio_rustls::TlsAcceptor;
use tokio_tungstenite::tungstenite::Message;
use tracing::{debug, error, info};

/// Global WebSocket client ID counter
static WS_CLIENT_ID_COUNTER: AtomicU64 = AtomicU64::new(0);

/// WSS (WebSocket over TLS) server that receives data from clients
/// and feeds it into the broadcast pipeline.
/// WebSocket clients do NOT receive broadcast data — only WebTransport clients do.
pub struct WsServer {
    listener: TcpListener,
    tls_acceptor: TlsAcceptor,
    broadcast_tx: mpsc::Sender<Bytes>,
}

impl WsServer {
    pub async fn new(
        addr: SocketAddr,
        broadcast_tx: mpsc::Sender<Bytes>,
    ) -> anyhow::Result<Self> {
        let tls_acceptor = Self::build_tls_acceptor()?;
        let listener = TcpListener::bind(addr).await?;
        Ok(Self {
            listener,
            tls_acceptor,
            broadcast_tx,
        })
    }

    /// Build TLS acceptor from CERT and KEY environment variables
    fn build_tls_acceptor() -> anyhow::Result<TlsAcceptor> {
        let cert_pem = env::var("CERT")
            .map_err(|_| anyhow::anyhow!("CERT environment variable not set"))?;
        let key_pem = env::var("KEY")
            .map_err(|_| anyhow::anyhow!("KEY environment variable not set"))?;

        let certs: Vec<_> = rustls_pemfile::certs(&mut cert_pem.as_bytes())
            .collect::<Result<_, _>>()?;
        let key = rustls_pemfile::private_key(&mut key_pem.as_bytes())?
            .ok_or_else(|| anyhow::anyhow!("No private key found in KEY"))?;

        let config = tokio_rustls::rustls::ServerConfig::builder()
            .with_no_client_auth()
            .with_single_cert(certs, key)?;

        Ok(TlsAcceptor::from(Arc::new(config)))
    }

    /// Accept WebSocket connections indefinitely
    pub async fn run(&self) -> anyhow::Result<()> {
        info!("WSS server listening");

        loop {
            let (stream, peer_addr) = self.listener.accept().await?;
            let tls_acceptor = self.tls_acceptor.clone();
            let broadcast_tx = self.broadcast_tx.clone();
            let client_id = WS_CLIENT_ID_COUNTER.fetch_add(1, Ordering::Relaxed);

            tokio::spawn(async move {
                if let Err(e) =
                    Self::handle_connection(stream, peer_addr, tls_acceptor, broadcast_tx, client_id).await
                {
                    error!("WSS connection error: {:?}", e);
                }
            });
        }
    }

    async fn handle_connection(
        stream: tokio::net::TcpStream,
        peer_addr: SocketAddr,
        tls_acceptor: TlsAcceptor,
        broadcast_tx: mpsc::Sender<Bytes>,
        client_id: u64,
    ) -> anyhow::Result<()> {
        // TLS handshake
        let tls_stream = tls_acceptor.accept(stream).await?;

        // WebSocket handshake over TLS
        let ws_stream = tokio_tungstenite::accept_async(tls_stream).await?;
        info!("WSS client {} connected from {}", client_id, peer_addr);

        let (_write, mut read) = ws_stream.split();

        // Receive-only: forward incoming WebSocket messages to the broadcast pipeline
        while let Some(msg) = read.next().await {
            match msg {
                Ok(Message::Binary(data)) => {
                    debug!("WSS client {} sent {} bytes", client_id, data.len());
                    let bytes = Bytes::from(data.to_vec());
                    if let Err(e) = broadcast_tx.send(bytes).await {
                        error!("Broadcast channel closed: {:?}", e);
                        break;
                    }
                }
                Ok(Message::Close(_)) => {
                    debug!("WSS client {} sent close", client_id);
                    break;
                }
                Err(e) => {
                    debug!("WSS client {} error: {:?}", client_id, e);
                    break;
                }
                _ => {}
            }
        }

        info!("WSS client {} disconnected", client_id);
        Ok(())
    }
}
