import { Link, createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/game')({ component: GameScreen })

function GameScreen() {
  return (
    <div className="flex items-start justify-end h-full p-4">
      <Link
        to="/result"
        className="px-6 py-3 bg-red-600 hover:bg-red-700 text-white font-bold rounded-xl shadow-lg transition-colors"
      >
        ゲーム終了
      </Link>
    </div>
  )
}
