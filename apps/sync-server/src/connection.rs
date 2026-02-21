use bytes::Bytes;
use tokio::sync::mpsc;
use tracing::{debug, error, info};
use wtransport::Connection;

/// Manages a single client connection with separate receiver and sender tasks
pub struct ClientConnection {
    id: u64,
    connection: Connection,
    outgoing_tx: mpsc::Sender<Bytes>,
    outgoing_rx: Option<mpsc::Receiver<Bytes>>,
}

impl ClientConnection {
    /// Create a new client connection
    pub fn new(id: u64, connection: Connection) -> Self {
        let (outgoing_tx, outgoing_rx) = mpsc::channel::<Bytes>(256);

        Self {
            id,
            connection,
            outgoing_tx,
            outgoing_rx: Some(outgoing_rx),
        }
    }

    /// Get the client ID
    pub fn id(&self) -> u64 {
        self.id
    }

    /// Get the outgoing sender channel (for broadcast registration)
    pub fn outgoing_tx(&self) -> mpsc::Sender<Bytes> {
        self.outgoing_tx.clone()
    }

    /// Spawn the sender task (handles outgoing datagrams)
    /// Returns a JoinHandle for the task
    pub fn spawn_sender(&mut self) -> tokio::task::JoinHandle<()> {
        let id = self.id;
        let connection = self.connection.clone();
        let rx = self.outgoing_rx.take().expect("sender already spawned");

        tokio::spawn(async move {
            Self::sender_loop(id, connection, rx).await;
        })
    }

    /// Spawn the receiver task (handles incoming datagrams)
    /// Returns a JoinHandle for the task
    pub fn spawn_receiver(
        &self,
        broadcast_tx: mpsc::Sender<Bytes>,
    ) -> tokio::task::JoinHandle<()> {
        let id = self.id;
        let connection = self.connection.clone();

        tokio::spawn(async move {
            Self::receiver_loop(id, connection, broadcast_tx).await;
        })
    }

    /// Sender loop - sends outgoing datagrams to the client
    async fn sender_loop(id: u64, connection: Connection, mut rx: mpsc::Receiver<Bytes>) {
        debug!("Client {} sender task started", id);

        while let Some(data) = rx.recv().await {
            if let Err(e) = connection.send_datagram(&data) {
                debug!("Failed to send datagram to client {}: {:?}", id, e);
                break;
            }
        }

        debug!("Client {} sender task terminated", id);
    }

    /// Receiver loop - receives incoming datagrams and broadcasts them
    async fn receiver_loop(id: u64, connection: Connection, broadcast_tx: mpsc::Sender<Bytes>) {
        debug!("Client {} receiver task started", id);

        loop {
            match connection.receive_datagram().await {
                Ok(data) => {
                    debug!("Client {} sent {} bytes", id, data.len());

                    // Convert to Bytes for zero-copy sharing
                    let bytes = Bytes::copy_from_slice(&data);

                    if let Err(e) = broadcast_tx.send(bytes).await {
                        error!("Broadcast channel closed: {:?}", e);
                        break;
                    }
                }
                Err(e) => {
                    debug!("Client {} disconnected: {:?}", id, e);
                    break;
                }
            }
        }

        info!("Client {} receiver task terminated", id);
    }
}
