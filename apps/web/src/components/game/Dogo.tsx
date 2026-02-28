import { extend, useTick } from "@pixi/react";
import { Assets, Sprite, Texture } from "pixi.js";
import { useEffect, useRef, useState } from "react";
import type { AnimState } from "../../game/types";

extend({ Sprite });

/** 同時に出現できる最大数 */
const MAX_DOGO = 6;
/** スケールのベース値 */
const BASE_SCALE = 0.2;

/** アニメーションのフレーム数 */
const RISE_FRAMES = 8; // 浮き上がり
const HOLD_FRAMES = 8; // 静止
const SINK_FRAMES = 8; // 沈む
const TOTAL_FRAMES = RISE_FRAMES + HOLD_FRAMES + SINK_FRAMES;

/** 浮き上がり・沈み量（px） */
const FLOAT_AMOUNT = 30;

type Props = {
  side: "left" | "right";
  getAnimState: () => AnimState;
};

export function Dogo({ side, getAnimState }: Props) {
  const [texture, setTexture] = useState<Texture | null>(null);
  const sizeRef = useRef({
    width: window.innerWidth,
    height: window.innerHeight,
  });
  const spriteRefs = useRef<(Sprite | null)[]>(Array(MAX_DOGO).fill(null));
  /** 各スロットの経過フレーム数（TOTAL_FRAMES 以上で非アクティブ） */
  const elapsedRef = useRef<number[]>(Array(MAX_DOGO).fill(TOTAL_FRAMES));
  /** 各スロットの静止時 y 座標 */
  const baseYRef = useRef<number[]>(Array(MAX_DOGO).fill(0));
  const prevAnimState = useRef<AnimState>("idle");

  useEffect(() => {
    Assets.load<Texture>("/assets/dogo.png").then(setTexture);
  }, []);

  useEffect(() => {
    const onResize = () => {
      sizeRef.current = {
        width: window.innerWidth,
        height: window.innerHeight,
      };
    };
    window.addEventListener("resize", onResize);
    return () => window.removeEventListener("resize", onResize);
  }, []);

  useTick(() => {
    const { width, height } = sizeRef.current;
    const animState = getAnimState();

    // punch が始まった瞬間にランダムな位置へ1〜3個出現
    if (animState === "punch" && prevAnimState.current !== "punch") {
      const count = Math.floor(Math.random() * 3) + 1;
      let placed = 0;
      for (let i = 0; i < MAX_DOGO && placed < count; i++) {
        if (elapsedRef.current[i] < TOTAL_FRAMES) continue;
        const sprite = spriteRefs.current[i];
        if (!sprite) continue;

        // fighter の位置から背後方向へ引いた位置にランダム配置
        const fighterX = side === "left" ? width * 0.25 : width * 0.75;
        const offset = width * (0.1 + Math.random() * 0.2);
        const behindX =
          side === "left"
            ? fighterX + offset // left fighter の背後（中央方向）
            : fighterX - offset; // right fighter の背後（中央方向）
        const scale = BASE_SCALE * (0.7 + Math.random() * 0.6);

        sprite.x = behindX;
        baseYRef.current[i] = height * (0.1 + Math.random() * 0.3);
        sprite.scale.set(scale);
        sprite.alpha = 0;
        sprite.visible = true;
        elapsedRef.current[i] = 0;
        placed++;
      }
    }

    prevAnimState.current = animState;

    // 各スロットのアニメーションを更新
    for (let i = 0; i < MAX_DOGO; i++) {
      const elapsed = elapsedRef.current[i];
      if (elapsed >= TOTAL_FRAMES) continue;

      const sprite = spriteRefs.current[i];
      if (!sprite) continue;

      const baseY = baseYRef.current[i];

      if (elapsed < RISE_FRAMES) {
        // 浮き上がり：下からフェードイン
        const t = elapsed / RISE_FRAMES;
        sprite.y = baseY + FLOAT_AMOUNT * (1 - t);
        sprite.alpha = t;
      } else if (elapsed < RISE_FRAMES + HOLD_FRAMES) {
        // 静止
        sprite.y = baseY;
        sprite.alpha = 1;
      } else {
        // 沈む：フェードアウト
        const t = (elapsed - RISE_FRAMES - HOLD_FRAMES) / SINK_FRAMES;
        sprite.y = baseY + FLOAT_AMOUNT * t;
        sprite.alpha = 1 - t;
      }

      elapsedRef.current[i]++;
      if (elapsedRef.current[i] >= TOTAL_FRAMES) {
        sprite.visible = false;
      }
    }
  });

  if (!texture) return null;

  return (
    <>
      {Array.from({ length: MAX_DOGO }, (_, i) => (
        <pixiSprite
          key={i}
          ref={(node: Sprite | null) => {
            spriteRefs.current[i] = node;
          }}
          texture={texture}
          anchor={{ x: 0.5, y: 0.5 }}
          x={-9999}
          y={-9999}
          scale={{ x: BASE_SCALE, y: BASE_SCALE }}
          visible={false}
        />
      ))}
    </>
  );
}
