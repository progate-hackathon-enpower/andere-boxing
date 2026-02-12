import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/rooms/$roomId/')({
  server:{
    handlers:{
      GET: async ({ params }) => {
        const { roomId } = params;

        // Here you would typically fetch room details from your database
        console.log(`Fetching details for room ID: ${roomId}`);

        return new Response(`Details for room ID: ${roomId}`, {
          status: 200,
        });
      },
      DELETE: async ({ params }) => {
        const { roomId } = params;

        // Here you would typically delete the room from your database
        console.log(`Deleting room ID: ${roomId}`);

        return new Response(`Room ID: ${roomId} deleted successfully!`, {
          status: 200,
        });
      }
    }
  },
  component: RouteComponent,
})

function RouteComponent() {
  return <div>Hello "/rooms/$roomId/"!</div>
}
