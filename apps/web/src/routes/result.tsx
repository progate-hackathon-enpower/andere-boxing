import { Link, createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/result")({ component: ResultScreen });

function ResultScreen() {
  return (
    <div className="flex h-full flex-col items-center justify-center">
      <h2 className="mb-4 text-5xl font-bold text-white drop-shadow-lg">
        結果
      </h2>
      <p className="mb-12 text-2xl font-bold text-yellow-400 drop-shadow">
        YOU WIN!
      </p>
      <Link
        to="/"
        className="rounded-xl bg-purple-600 px-8 py-4 text-xl font-bold text-white shadow-lg transition-colors hover:bg-purple-700"
      >
        タイトルへ戻る
      </Link>
    </div>
  );
}
