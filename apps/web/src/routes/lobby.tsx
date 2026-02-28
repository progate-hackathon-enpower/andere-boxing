import { useNavigate, createFileRoute } from "@tanstack/react-router";
import { useGameState } from "../contexts/GameContext";

export const Route = createFileRoute("/lobby")({ component: LobbyScreen });

function LobbyScreen() {
  const navigate = useNavigate();
  const { reset } = useGameState();

  const handleStartGame = () => {
    reset();
    navigate({ to: "/game" });
  };

  return (
    <div className="flex h-full flex-col items-center justify-center">
      <h2 className="pixel-title mb-4 text-3xl text-white">待機中...</h2>
      <p className="pixel-text mb-12 text-white/80">対戦相手を探しています</p>
      <button
        onClick={handleStartGame}
        className="pixel-btn pixel-btn-green text-lg"
      >
        対戦開始
      </button>
    </div>
  );
}
