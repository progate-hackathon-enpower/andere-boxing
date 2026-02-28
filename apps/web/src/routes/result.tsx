import { Link, createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/result")({ component: ResultScreen });

function ResultScreen() {
  return (
    <div className="flex h-full flex-col items-center justify-center">
      <h2 className="pixel-title mb-4 text-4xl text-white">結果</h2>
      <p
        className="pixel-title mb-12 text-3xl text-yellow-400"
        style={{ textShadow: "4px 4px 0 #78350f, 8px 8px 0 rgba(0,0,0,0.4)" }}
      >
        YOU WIN!
      </p>
      <Link to="/" className="pixel-btn pixel-btn-purple text-lg">
        タイトルへ戻る
      </Link>
    </div>
  );
}
