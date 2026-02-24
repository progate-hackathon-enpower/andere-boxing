/**
 * Agones Game Server Allocation Client
 */

export interface GameServerPort {
  name: string;
  port: number;
}

export interface GameServer {
  metadata: {
    name: string;
    namespace: string;
    labels?: Record<string, string>;
  };
  status: {
    state: "Ready" | "Allocated" | "Shutdown" | "Error";
    address: string;
    ports: GameServerPort[];
  };
}

export interface AllocationResponse {
  gameServerName: string;
  address: string;
  ports: GameServerPort[];
}

export class AgonesClient {
  private baseUrl: string;
  private namespace: string;

  constructor(options: { baseUrl: string; namespace?: string }) {
    this.baseUrl = options.baseUrl.replace(/\/$/, "");
    this.namespace = options.namespace ?? "default";
  }

  /**
   * Allocate a game server for a specific room
   */
  async allocateForRoom(roomId: string): Promise<AllocationResponse> {
    const response = await fetch(`${this.baseUrl}/gameserverallocation`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        namespace: this.namespace,
        gameServerSelectors: [{ gameServerState: "Ready" }],
        metadata: {
          labels: { "agones.dev/room-id": roomId },
        },
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to allocate: ${await response.text()}`);
    }

    return response.json();
  }

  /**
   * Find an allocated server by room ID
   */
  async findServerByRoomId(roomId: string): Promise<GameServer | null> {
    const response = await fetch(
      `${this.baseUrl}/namespaces/${this.namespace}/gameservers?labelSelector=agones.dev/room-id=${roomId}`,
      { headers: { "Content-Type": "application/json" } },
    );

    if (!response.ok) {
      throw new Error(`Failed to find server: ${await response.text()}`);
    }

    const data = await response.json();
    const servers: GameServer[] = data.items ?? [];
    return servers.find((s) => s.status.state === "Allocated") ?? null;
  }
}
