use std::sync::Arc;
use std::time::Duration;
use tokio::sync::RwLock;
use tracing::{error, info};

/// Agones SDK wrapper with health check thread
pub struct AgonesManager {
    sdk: Arc<RwLock<agones::Sdk>>,
}

impl AgonesManager {
    /// Initialize the Agones SDK and mark the server as ready
    pub async fn init() -> anyhow::Result<Self> {
        info!("Initializing Agones SDK...");

        let sdk = agones::Sdk::new(None, None)
            .await
            .map_err(|e| anyhow::anyhow!("Failed to initialize Agones SDK: {:?}", e))?;

        let sdk = Arc::new(RwLock::new(sdk));

        info!("Agones SDK initialized successfully");

        Ok(Self { sdk })
    }

    /// Mark the game server as ready to receive connections
    pub async fn ready(&self) -> anyhow::Result<()> {
        let mut sdk = self.sdk.write().await;
        sdk.ready()
            .await
            .map_err(|e| anyhow::anyhow!("Failed to mark server as ready: {:?}", e))?;

        info!("Game server marked as ready");
        Ok(())
    }

    /// Start a background thread that sends health pings
    pub fn start_health_thread(&self) {
        let sdk = self.sdk.clone();

        tokio::spawn(async move {
            let mut interval = tokio::time::interval(Duration::from_secs(2));

            loop {
                interval.tick().await;

                let sdk_guard = sdk.write().await;
                if let Err(e) = sdk_guard.health_check().send(()).await {
                    error!("Failed to send health ping: {:?}", e);
                }
            }
        });

        info!("Agones health check thread started");
    }

    /// Shutdown the game server
    pub async fn shutdown(&self) -> anyhow::Result<()> {
        let mut sdk = self.sdk.write().await;
        sdk.shutdown()
            .await
            .map_err(|e| anyhow::anyhow!("Failed to shutdown server: {:?}", e))?;

        info!("Game server shutdown requested");
        Ok(())
    }
}
