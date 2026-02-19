import { Link, createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/lobby')({ component: LobbyScreen })

function LobbyScreen() {
  return (
    <div className="flex flex-col items-center justify-center h-full">
      <h2 className="text-4xl font-bold text-white mb-4 drop-shadow-lg">待機中...</h2>
      <p className="text-white/80 mb-12 drop-shadow">対戦相手を探しています</p>
      <Link
        to="/game"
        className="px-8 py-4 bg-green-600 hover:bg-green-700 text-white text-xl font-bold rounded-xl shadow-lg transition-colors"
      >
        対戦開始
      </Link>
    </div>
  )
}
