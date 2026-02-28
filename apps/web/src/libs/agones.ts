/**
 * Agones Game Server Allocation Client
 */

import { EksClient } from "./eks";

export interface GameServerInfo {
  address: string;
  port: number;
}

export class AgonesClient {
  private namespace: string;
  private eks: EksClient;

  constructor(options: { namespace?: string; clusterName?: string }) {
    this.namespace = options.namespace ?? "sync-server";
    this.eks = new EksClient(options.clusterName);
  }

  /**
   * GameServerAllocation を作成してルームにサーバーを割り当て
   */
  async allocateForRoom(roomId: string): Promise<GameServerInfo> {
    const body = {
      apiVersion: "allocation.agones.dev/v1",
      kind: "GameServerAllocation",
      metadata: { namespace: this.namespace },
      spec: {
        selectors: [{ matchLabels: { app: "sync-server" } }],
        metadata: {
          labels: { "agones.dev/room-id": roomId },
        },
      },
    };

    const response = await this.eks.request(
      `/apis/allocation.agones.dev/v1/namespaces/${this.namespace}/gameserverallocations`,
      { method: "POST", body: JSON.stringify(body) },
    );

    if (!response.ok) {
      throw new Error(`Failed to allocate: ${await response.text()}`);
    }

    const data = await response.json();
    return {
      address: data.status?.address,
      port: data.status?.ports?.[0]?.port,
    };
  }

  /**
   * ルーム ID で割り当て済みの GameServer を検索
   */
  async findServerByRoomId(roomId: string): Promise<GameServerInfo | null> {
    const response = await this.eks.request(
      `/apis/agones.dev/v1/namespaces/${this.namespace}/gameservers?labelSelector=agones.dev/room-id=${encodeURIComponent(roomId)}`,
    );

    if (!response.ok) {
      throw new Error(`Failed to find server: ${await response.text()}`);
    }

    const data = await response.json();

    const allocated = (data.items ?? []).find(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      (item: any) => item.status?.state === "Allocated",
    );

    if (!allocated) return null;

    return {
      address: allocated.status?.address,
      port: allocated.status?.ports?.[0]?.port,
    };
  }
}
