use std::sync::Arc;

use bytes::Bytes;
use dashmap::DashMap;
use futures::future::join_all;
use tokio::sync::mpsc;
use tracing::debug;

/// Manages broadcast distribution to all connected clients
pub struct BroadcastManager {
    clients: Arc<DashMap<u64, mpsc::Sender<Bytes>>>,
}

impl BroadcastManager {
    pub fn new() -> Self {
        Self {
            clients: Arc::new(DashMap::new()),
        }
    }

    /// Register a new client's send channel
    pub fn register(&self, id: u64, tx: mpsc::Sender<Bytes>) {
        self.clients.insert(id, tx);
    }

    /// Unregister a client
    pub fn unregister(&self, id: u64) {
        self.clients.remove(&id);
    }

    /// Clone the internal clients map for sharing
    pub fn clients(&self) -> Arc<DashMap<u64, mpsc::Sender<Bytes>>> {
        self.clients.clone()
    }

    /// Spawn the broadcast dispatcher task
    pub fn spawn_dispatcher(&self, mut rx: mpsc::Receiver<Bytes>) {
        let clients = self.clients.clone();

        tokio::spawn(async move {
            while let Some(data) = rx.recv().await {
                // Collect all client senders (quick iteration, no blocking)
                let senders: Vec<_> = clients
                    .iter()
                    .map(|entry| (*entry.key(), entry.value().clone()))
                    .collect();

                // Fan out to all clients in parallel using try_send (non-blocking)
                let send_futures = senders.into_iter().map(|(client_id, tx)| {
                    let data = data.clone(); // Bytes clone is cheap (reference count)
                    async move {
                        if let Err(e) = tx.try_send(data) {
                            debug!(
                                "Client {} send buffer full or disconnected: {:?}",
                                client_id, e
                            );
                        }
                    }
                });

                join_all(send_futures).await;
            }
        });
    }
}

impl Default for BroadcastManager {
    fn default() -> Self {
        Self::new()
    }
}
