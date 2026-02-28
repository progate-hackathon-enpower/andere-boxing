import { Link, createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/lobby")({ component: LobbyScreen });

function LobbyScreen() {
  return (
    <div className="flex h-full flex-col items-center justify-center">
      <h2 className="mb-4 text-4xl font-bold text-white drop-shadow-lg">
        待機中...
      </h2>
      <p className="mb-12 text-white/80 drop-shadow">対戦相手を探しています</p>
      <Link
        to="/game"
        className="rounded-xl bg-green-600 px-8 py-4 text-xl font-bold text-white shadow-lg transition-colors hover:bg-green-700"
      >
        対戦開始
      </Link>
    </div>
  );
}
