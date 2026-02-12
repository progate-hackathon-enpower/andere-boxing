import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/rooms/')({
    server: {
        handlers:{
            POST: async ({ request }) => {
                const formData = await request.formData();
                const roomName = formData.get('roomName');

                // Here you would typically create the room in your database
                console.log(`Creating room: ${roomName}`);

                return new Response(`Room "${roomName}" created successfully!`, {
                    status: 201,
                });
            },
        }

    },
    component: RouteComponent,
})

function RouteComponent() {
  return <div>Hello "/rooms/"!</div>
}
