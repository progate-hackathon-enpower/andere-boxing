import { Link, createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/')({ component: StartScreen })

function StartScreen() {
  return (
    <div className="flex flex-col items-center justify-center h-full">
      <h1 className="text-6xl font-bold text-white mb-4 drop-shadow-lg">
        Andere Boxing
      </h1>
      <p className="text-xl text-white/80 mb-12 drop-shadow">2D 対戦ゲーム</p>
      <Link
        to="/lobby"
        className="px-8 py-4 bg-purple-600 hover:bg-purple-700 text-white text-xl font-bold rounded-xl shadow-lg transition-colors"
      >
        ゲームを始める
      </Link>
    </div>
  )
}
