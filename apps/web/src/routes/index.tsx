import { createFileRoute, useNavigate } from "@tanstack/react-router";

export const Route = createFileRoute("/")({ component: StartScreen });

function StartScreen() {
  const navigate = useNavigate();

  const handleStart = async () => {
    const res = await fetch("/rooms", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({}),
    });
    const data = await res.json();
    if (data.roomId) {
      navigate({ to: "/rooms/$roomId", params: { roomId: data.roomId } });
    }
  };

  return (
    <div className="flex h-full flex-col items-center justify-center">
      <h1 className="pixel-title mb-4 text-4xl text-white">RUSH BATTLE!!</h1>
      <p className="pixel-text mb-12 text-lg text-white/80">2D FIGHTING GAME</p>
      <button
        onClick={handleStart}
        className="pixel-btn pixel-btn-purple text-lg"
      >
        START GAME
      </button>
    </div>
  );
}
