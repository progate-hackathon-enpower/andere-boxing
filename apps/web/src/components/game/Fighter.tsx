import { extend, useTick } from "@pixi/react";
import { AnimatedSprite, Texture } from "pixi.js";
import { useCallback, useEffect, useRef, useState } from "react";
import { GAME_CONFIG } from "../../game/config";
import { FRAME_COUNT, loadFighterSprite } from "../../game/fighterSprite";
import type { AnimState } from "../../game/types";

extend({ AnimatedSprite });

// フレームサイズ 170.2×204.8 px を画面上で表示する際のスケール
const SPRITE_SCALE = 1.5;

/** ゲームフレーム数とコマ数から animationSpeed を計算する */
function getAnimSpeed(animState: AnimState): number {
  if (animState === "idle") return FRAME_COUNT / 30;
  return FRAME_COUNT / GAME_CONFIG.animDuration[animState];
}

type Props = {
  side: "left" | "right";
  /** 毎フレーム呼び出されるコールバック。ゲームループの ref から最新の animState を取得する */
  getAnimState: () => AnimState;
};

export function Fighter({ side, getAnimState }: Props) {
  const [allTextures, setAllTextures] = useState<Record<
    AnimState,
    Texture[]
  > | null>(null);
  const [size, setSize] = useState({
    width: window.innerWidth,
    height: window.innerHeight,
  });
  const spriteRef = useRef<AnimatedSprite | null>(null);
  const prevAnimState = useRef<AnimState>("idle");

  // キャラクター別スプライトシートをロード（モジュールキャッシュにより一度だけ）
  useEffect(() => {
    loadFighterSprite(side === "left" ? "jotaro" : "dio").then(setAllTextures);
  }, [side]);

  useEffect(() => {
    const onResize = () =>
      setSize({ width: window.innerWidth, height: window.innerHeight });
    window.addEventListener("resize", onResize);
    return () => window.removeEventListener("resize", onResize);
  }, []);

  // マウント直後に idle アニメーションを開始する
  const handleRef = useCallback((node: AnimatedSprite | null) => {
    spriteRef.current = node;
    if (node) node.gotoAndPlay(0);
  }, []);

  // 毎フレーム animState の変化を検知してアニメーションを切り替える
  useTick(() => {
    const sprite = spriteRef.current;
    if (!sprite || !allTextures) return;

    const animState = getAnimState();
    if (animState === prevAnimState.current) return;
    prevAnimState.current = animState;

    sprite.textures = allTextures[animState];
    sprite.animationSpeed = getAnimSpeed(animState);

    if (animState === "ko") {
      // ko: 最終フレームで停止
      sprite.loop = false;
      sprite.onComplete = () => {
        spriteRef.current?.gotoAndStop(
          (spriteRef.current.totalFrames ?? 1) - 1,
        );
      };
      sprite.gotoAndPlay(0);
    } else if (animState === "idle") {
      sprite.loop = true;
      sprite.onComplete = undefined;
      sprite.gotoAndPlay(0);
    } else {
      // punch / defend / hurt: 単発再生
      sprite.loop = false;
      sprite.onComplete = undefined;
      sprite.gotoAndPlay(0);
    }
  });

  if (!allTextures) return null;

  const x = side === "left" ? size.width * 0.25 : size.width * 0.75;
  const y = size.height * 0.85;
  const scaleX = side === "right" ? -SPRITE_SCALE : SPRITE_SCALE;

  return (
    <pixiAnimatedSprite
      ref={handleRef}
      // eslint-disable-next-line react/no-unknown-property
      textures={allTextures.idle}
      // eslint-disable-next-line react/no-unknown-property
      animationSpeed={getAnimSpeed("idle")}
      // eslint-disable-next-line react/no-unknown-property
      loop={true}
      anchor={{ x: 0.5, y: 1 }}
      x={x}
      y={y}
      scale={{ x: scaleX, y: SPRITE_SCALE }}
    />
  );
}
