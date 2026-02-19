import { extend } from '@pixi/react'
import { Assets, Sprite, Texture } from 'pixi.js'
import { useEffect, useState } from 'react'

extend({ Sprite })

export function Background() {
  const [texture, setTexture] = useState<Texture | null>(null)
  // resizeTo={window} により PixiJS canvas は常に window サイズと一致するため
  // app.screen ではなく window.innerWidth/Height を使うことで renderer 初期化タイミングを回避
  const [size, setSize] = useState({
    width: window.innerWidth,
    height: window.innerHeight,
  })

  useEffect(() => {
    Assets.load<Texture>('/assets/background.png').then(setTexture)
  }, [])

  useEffect(() => {
    const onResize = () => {
      setSize({ width: window.innerWidth, height: window.innerHeight })
    }
    window.addEventListener('resize', onResize)
    return () => {
      window.removeEventListener('resize', onResize)
    }
  }, [])

  if (!texture) return null

  return (
    <pixiSprite texture={texture} width={size.width} height={size.height} />
  )
}
