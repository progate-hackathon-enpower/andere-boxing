import { extend, useTick } from "@pixi/react";
import { Graphics } from "pixi.js";
import { useCallback, useEffect, useRef, useState } from "react";
import type { AnimState } from "../../game/types";

extend({ Graphics });

type Props = {
  side: "left" | "right";
  /** 毎フレーム呼び出されるコールバック。ゲームループの ref から最新の animState を取得する */
  getAnimState: () => AnimState;
};

const FIGHTER_WIDTH = 80;
const FIGHTER_HEIGHT = 160;

const ANIM_COLOR: Record<AnimState, number> = {
  idle: 0xffffff,
  punch: 0xff3333,
  defend: 0x3333ff,
  hurt: 0xffff00,
  ko: 0x888888,
};

export function Fighter({ side, getAnimState }: Props) {
  const [size, setSize] = useState({
    width: window.innerWidth,
    height: window.innerHeight,
  });

  useEffect(() => {
    const onResize = () => {
      setSize({ width: window.innerWidth, height: window.innerHeight });
    };
    window.addEventListener("resize", onResize);
    return () => window.removeEventListener("resize", onResize);
  }, []);

  const graphicsRef = useRef<Graphics>(null);

  // マウント時・リサイズ再描画時の draw（pixiGraphics が draw を必須とするため提供）
  const draw = useCallback(
    (g: Graphics) => {
      g.clear();
      g.rect(0, 0, FIGHTER_WIDTH, FIGHTER_HEIGHT);
      g.fill(ANIM_COLOR[getAnimState()]);
    },
    [getAnimState],
  );

  // 毎フレーム最新の animState を読み取り、直接 pixi Graphics を更新する
  useTick(() => {
    const g = graphicsRef.current;
    if (!g) return;
    const animState = getAnimState();
    g.clear();
    g.rect(0, 0, FIGHTER_WIDTH, FIGHTER_HEIGHT);
    g.fill(ANIM_COLOR[animState]);
  });

  const x = side === "left" ? size.width * 0.25 : size.width * 0.75;
  const y = size.height * 0.85;

  return (
    <pixiGraphics
      ref={graphicsRef}
      draw={draw}
      x={x}
      y={y}
      pivot={{ x: FIGHTER_WIDTH / 2, y: FIGHTER_HEIGHT }}
      scale={{ x: side === "right" ? -1 : 1, y: 1 }}
    />
  );
}
