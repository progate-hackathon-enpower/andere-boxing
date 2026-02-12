import { createFileRoute } from '@tanstack/react-router'
import '../App.css'

export const Route = createFileRoute('/')({ component: App })

function App() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
      <div className="container mx-auto px-4 py-16">
        {/* Hero Section */}
        <header className="text-center mb-16">
          <h1 className="text-5xl font-bold text-white mb-4">
            Andere Boxing
          </h1>
          <p className="text-xl text-purple-200">
            Tailwind CSS is working!
          </p>
        </header>

        {/* Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-16">
          {[
            { title: 'Typography', desc: 'Font sizes, weights, and colors' },
            { title: 'Flexbox & Grid', desc: 'Layout utilities' },
            { title: 'Spacing', desc: 'Margin and padding' },
          ].map((card) => (
            <div
              key={card.title}
              className="bg-white/10 backdrop-blur-md rounded-2xl p-6 border border-white/20 hover:bg-white/20 transition-all duration-300 hover:scale-105"
            >
              <h3 className="text-xl font-semibold text-white mb-2">{card.title}</h3>
              <p className="text-purple-200">{card.desc}</p>
            </div>
          ))}
        </div>

        {/* Buttons */}
        <div className="flex flex-wrap justify-center gap-4 mb-16">
          <button className="px-6 py-3 bg-purple-600 hover:bg-purple-700 text-white font-medium rounded-lg transition-colors">
            Primary Button
          </button>
          <button className="px-6 py-3 bg-transparent border-2 border-purple-400 text-purple-400 hover:bg-purple-400 hover:text-white font-medium rounded-lg transition-all">
            Secondary Button
          </button>
          <button className="px-6 py-3 bg-gradient-to-r from-pink-500 to-purple-600 text-white font-medium rounded-lg hover:opacity-90 transition-opacity">
            Gradient Button
          </button>
        </div>

        {/* Color Palette */}
        <div className="mb-16">
          <h2 className="text-2xl font-bold text-white text-center mb-6">Color Palette</h2>
          <div className="flex flex-wrap justify-center gap-3">
            {['bg-red-500', 'bg-orange-500', 'bg-yellow-500', 'bg-green-500', 'bg-blue-500', 'bg-indigo-500', 'bg-purple-500', 'bg-pink-500'].map((color) => (
              <div
                key={color}
                className={`${color} w-16 h-16 rounded-xl shadow-lg hover:scale-110 transition-transform`}
              />
            ))}
          </div>
        </div>

        {/* Badge & Pills */}
        <div className="flex flex-wrap justify-center gap-2">
          <span className="px-3 py-1 bg-green-500/20 text-green-400 text-sm rounded-full">Success</span>
          <span className="px-3 py-1 bg-yellow-500/20 text-yellow-400 text-sm rounded-full">Warning</span>
          <span className="px-3 py-1 bg-red-500/20 text-red-400 text-sm rounded-full">Error</span>
          <span className="px-3 py-1 bg-blue-500/20 text-blue-400 text-sm rounded-full">Info</span>
        </div>
      </div>
    </div>
  )
}
