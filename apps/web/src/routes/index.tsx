import { Link, createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/")({ component: StartScreen });

function StartScreen() {
  return (
    <div className="flex h-full flex-col items-center justify-center">
      <h1 className="mb-4 text-6xl font-bold text-white drop-shadow-lg">
        Andere Boxing
      </h1>
      <p className="mb-12 text-xl text-white/80 drop-shadow">2D 対戦ゲーム</p>
      <Link
        to="/lobby"
        className="rounded-xl bg-purple-600 px-8 py-4 text-xl font-bold text-white shadow-lg transition-colors hover:bg-purple-700"
      >
        ゲームを始める
      </Link>
    </div>
  );
}
