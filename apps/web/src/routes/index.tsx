import { Link, createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/")({ component: StartScreen });

function StartScreen() {
  return (
    <div className="flex h-full flex-col items-center justify-center">
      <h1 className="pixel-title mb-4 text-4xl text-white">RUSH BATTLE!!</h1>
      <p className="pixel-text mb-12 text-lg text-white/80">2D 対戦ゲーム</p>
      <Link to="/lobby" className="pixel-btn pixel-btn-purple text-lg">
        ゲームを始める
      </Link>
    </div>
  );
}
