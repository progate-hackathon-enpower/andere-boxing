import { Link, createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/game")({
  component: GameScreen,
});

function GameScreen() {
  return (
    <div className="flex h-full flex-col items-start justify-start p-4">
      <div className="flex-1">{/* Game content renders here */}</div>
      <div className="flex h-full items-start justify-end p-4">
        <Link
          to="/result"
          className="rounded-xl bg-red-600 px-6 py-3 font-bold text-white shadow-lg transition-colors hover:bg-red-700"
        >
          ゲーム終了
        </Link>
      </div>
    </div>
  );
}
