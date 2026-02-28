import { createFileRoute, Link, useParams } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { AgonesClient } from "@/libs/agones";
import { getGameTransport } from "../../../libs/gameTransport";
import { HUD } from "../../../components/game/HUD";
import { useGameState } from "../../../contexts/GameContext";

const agones = new AgonesClient({
  clusterName: process.env.EKS_CLUSTER_NAME,
  namespace: process.env.AGONES_NAMESPACE ?? "sync-server",
});

export const Route = createFileRoute("/rooms/$roomId/")({
  server: {
    handlers: {
      GET: async ({ params }) => {
        const { roomId } = params;

        try {
          const server = await agones.findServerByRoomId(roomId);

          if (!server) {
            return Response.json({ error: "Room not found" }, { status: 404 });
          }

          return Response.json({
            roomId,
            address: server.address,
            port: server.port,
          });
        } catch (error) {
          return Response.json(
            {
              error:
                error instanceof Error
                  ? error.message
                  : "Failed to find server",
            },
            { status: 500 },
          );
        }
      },
    },
  },
  component: RoomPage,
});

type RoomPhase = "lobby" | "fighting" | "result";

function RoomPage() {
  const { roomId } = useParams({ from: "/rooms/$roomId/" });
  const [phase, setPhase] = useState<RoomPhase>("lobby");
  const [error, setError] = useState<string | null>(null);
  const { reset, gameStateRef } = useGameState();

  // ルームに入ったら sync-server に WebTransport 接続
  useEffect(() => {
    let cancelled = false;

    const connectToServer = async () => {
      try {
        const res = await fetch(`/rooms/${roomId}`, { method: "GET" });
        if (!res.ok) {
          setError("Room not found");
          return;
        }
        const data = await res.json();
        const transport = getGameTransport();
        await transport.connect(`${data.address}:${data.port}`);
      } catch (e) {
        if (!cancelled) {
          console.error("Failed to connect:", e);
          setError("Failed to connect to server");
        }
      }
    };

    connectToServer();

    return () => {
      cancelled = true;
      getGameTransport().close();
    };
  }, [roomId]);

  const handleStartGame = () => {
    reset();
    setPhase("fighting");
  };

  // fighting 中に GameState の phase が result になったら遷移
  useEffect(() => {
    if (phase !== "fighting") return;

    let rafId: number;
    const poll = () => {
      const state = gameStateRef.current;
      if (state?.phase === "result") {
        setPhase("result");
        return;
      }
      rafId = requestAnimationFrame(poll);
    };
    rafId = requestAnimationFrame(poll);
    return () => cancelAnimationFrame(rafId);
  }, [phase, gameStateRef]);

  if (error) {
    return (
      <div className="flex h-full flex-col items-center justify-center">
        <h2 className="pixel-title mb-4 text-3xl text-red-400">{error}</h2>
        <Link to="/" className="pixel-btn pixel-btn-purple text-lg">
          BACK TO TITLE
        </Link>
      </div>
    );
  }

  if (phase === "lobby") {
    return (
      <div className="flex h-full flex-col items-center justify-center">
        <h2 className="pixel-title mb-4 text-3xl text-white">WAITING...</h2>
        <p className="pixel-text mb-4 text-white/80">ROOM: {roomId}</p>
        <p className="pixel-text mb-12 text-white/80">
          LOOKING FOR OPPONENT...
        </p>
        <button
          onClick={handleStartGame}
          className="pixel-btn pixel-btn-green text-lg"
        >
          FIGHT!!
        </button>
      </div>
    );
  }

  if (phase === "result") {
    return (
      <div className="flex h-full flex-col items-center justify-center">
        <h2 className="pixel-title mb-4 text-4xl text-white">RESULT</h2>
        <p
          className="pixel-title mb-12 text-3xl text-yellow-400"
          style={{ textShadow: "4px 4px 0 #78350f, 8px 8px 0 rgba(0,0,0,0.4)" }}
        >
          JOTARO WIN!
        </p>
        <Link to="/" className="pixel-btn pixel-btn-purple text-lg">
          BACK TO TITLE
        </Link>
      </div>
    );
  }

  // fighting
  return <HUD />;
}
