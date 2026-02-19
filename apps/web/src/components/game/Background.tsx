import { extend, useApplication } from '@pixi/react'
import { Assets, Sprite, Texture } from 'pixi.js'
import { useEffect, useState } from 'react'

extend({ Sprite })

export function Background() {
  const { app } = useApplication()
  const [texture, setTexture] = useState<Texture | null>(null)
  const [size, setSize] = useState({
    width: app.screen.width,
    height: app.screen.height,
  })

  useEffect(() => {
    Assets.load<Texture>('/assets/background.png').then(setTexture)
  }, [])

  // ウィンドウリサイズ時にスプライトサイズを同期する
  useEffect(() => {
    const onResize = () => {
      setSize({ width: app.screen.width, height: app.screen.height })
    }
    app.renderer.on('resize', onResize)
    return () => {
      app.renderer.off('resize', onResize)
    }
  }, [app])

  if (!texture) return null

  return (
    <pixiSprite texture={texture} width={size.width} height={size.height} />
  )
}
