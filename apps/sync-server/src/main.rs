use std::net::{Ipv4Addr, SocketAddr};

use tracing::info;

mod broadcast;
mod connection;
mod libs;
mod server;
mod ws_server;

use libs::agones::AgonesManager;
use server::GameServer;
use ws_server::WsServer;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt::init();

    // Initialize Agones SDK
    let agones = AgonesManager::init().await?;
    agones.ready().await?;
    agones.start_health_thread();

    // Start game server (WebTransport on UDP:4433)
    let wt_addr = SocketAddr::new(Ipv4Addr::UNSPECIFIED.into(), 4433);
    info!("Starting WebTransport server on {}", wt_addr);
    let game_server = GameServer::new(wt_addr).await?;

    // Start WebSocket server (TCP:4434), sharing the same broadcast channel
    let ws_addr = SocketAddr::new(Ipv4Addr::UNSPECIFIED.into(), 4434);
    info!("Starting WebSocket server on {}", ws_addr);
    let ws_server = WsServer::new(ws_addr, game_server.broadcast_tx()).await?;

    // Run both servers concurrently
    tokio::select! {
        result = game_server.run() => result,
        result = ws_server.run() => result,
    }
}
