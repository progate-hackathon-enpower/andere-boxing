import { createFileRoute } from '@tanstack/react-router'
import { AgonesClient } from '@/libs/agones'

const agones = new AgonesClient({
  baseUrl: process.env.AGONES_ALLOCATOR_URL ?? 'http://agones-allocator.agones-system.svc',
  namespace: process.env.AGONES_NAMESPACE ?? 'default',
})

export const Route = createFileRoute('/rooms/$roomId/')({
  server: {
    handlers: {
      GET: async ({ params }) => {
        const { roomId } = params

        try {
          const server = await agones.findServerByRoomId(roomId)

          if (!server) {
            return Response.json({ error: 'Room not found' }, { status: 404 })
          }

          return Response.json({
            roomId,
            server: {
              name: server.metadata.name,
              address: server.status.address,
              ports: server.status.ports,
              state: server.status.state,
            },
          })
        } catch (error) {
          return Response.json(
            { error: error instanceof Error ? error.message : 'Failed to find server' },
            { status: 500 }
          )
        }
      },
    },
  },
  component: RouteComponent,
})

function RouteComponent() {
  return <div>Hello "/rooms/$roomId/"!</div>
}
