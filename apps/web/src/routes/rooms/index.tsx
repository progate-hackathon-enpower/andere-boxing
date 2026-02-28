import { createFileRoute } from "@tanstack/react-router";
import { AgonesClient } from "@/libs/agones";

function generateRoomId(): string {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const pick = () =>
    Array.from(
      { length: 4 },
      () => chars[Math.floor(Math.random() * chars.length)],
    ).join("");
  return `${pick()}-${pick()}`;
}

const agones = new AgonesClient({
  clusterName: process.env.EKS_CLUSTER_NAME,
  namespace: process.env.AGONES_NAMESPACE ?? "sync-server",
});

export const Route = createFileRoute("/rooms/")({
  server: {
    handlers: {
      POST: async ({ request }) => {
        const body = await request.json();
        const roomId = body.roomId ?? generateRoomId();

        try {
          const server = await agones.allocateForRoom(roomId);
          return Response.json(
            { roomId, address: server.address, port: server.port },
            { status: 201 },
          );
        } catch (error) {
          return Response.json(
            {
              error:
                error instanceof Error
                  ? error.message
                  : "Failed to allocate server",
            },
            { status: 500 },
          );
        }
      },
    },
  },
  component: RouteComponent,
});

function RouteComponent() {
  return <div>Hello &quot;/rooms/&quot;!</div>;
}
