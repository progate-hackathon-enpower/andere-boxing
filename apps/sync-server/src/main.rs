use std::net::{Ipv4Addr, SocketAddr};

use tracing::info;

mod broadcast;
mod connection;
mod libs;
mod server;

use libs::agones::AgonesManager;
use server::GameServer;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt::init();

    // Initialize Agones SDK
    let agones = AgonesManager::init().await?;
    agones.ready().await?;
    agones.start_health_thread();

    // Start game server
    let addr = SocketAddr::new(Ipv4Addr::LOCALHOST.into(), 4433);
    info!("Starting server on {}", addr);

    let server = GameServer::new(addr).await?;
    server.run().await
}
