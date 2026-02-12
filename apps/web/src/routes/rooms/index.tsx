import { createFileRoute } from '@tanstack/react-router'
import { AgonesClient } from '@/libs/agones'

const agones = new AgonesClient({
  baseUrl: process.env.AGONES_ALLOCATOR_URL ?? 'http://agones-allocator.agones-system.svc',
  namespace: process.env.AGONES_NAMESPACE ?? 'default',
})

export const Route = createFileRoute('/rooms/')({
  server: {
    handlers: {
      POST: async ({ request }) => {
        const body = await request.json()
        const roomId = body.roomId ?? crypto.randomUUID()

        try {
          const server = await agones.allocateForRoom(roomId)
          return Response.json({
            roomId,
            server: {
              name: server.gameServerName,
              address: server.address,
              ports: server.ports,
            },
          }, { status: 201 })
        } catch (error) {
          return Response.json(
            { error: error instanceof Error ? error.message : 'Failed to allocate server' },
            { status: 500 }
          )
        }
      },
    },
  },
  component: RouteComponent,
})

function RouteComponent() {
  return <div>Hello "/rooms/"!</div>
}
