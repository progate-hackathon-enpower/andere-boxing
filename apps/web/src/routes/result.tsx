import { Link, createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/result')({ component: ResultScreen })

function ResultScreen() {
  return (
    <div className="flex flex-col items-center justify-center h-full">
      <h2 className="text-5xl font-bold text-white mb-4 drop-shadow-lg">結果</h2>
      <p className="text-2xl text-yellow-400 mb-12 drop-shadow font-bold">YOU WIN!</p>
      <Link
        to="/"
        className="px-8 py-4 bg-purple-600 hover:bg-purple-700 text-white text-xl font-bold rounded-xl shadow-lg transition-colors"
      >
        タイトルへ戻る
      </Link>
    </div>
  )
}
