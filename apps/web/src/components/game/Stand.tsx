import { extend, useTick } from "@pixi/react";
import { AnimatedSprite, Texture } from "pixi.js";
import { useCallback, useEffect, useRef, useState } from "react";
import {
  STAND_FRAME_COUNT,
  loadStandSprite,
  type StandCharName,
} from "../../game/standSprite";
import type { AnimState } from "../../game/types";

extend({ AnimatedSprite });

const SPRITE_SCALE = 1.5;

// Fighter と同じ速度設定
const ANIM_SPEED_DIVISOR: Record<AnimState, number> = {
  idle: 55,
  punch: 30,
  defend: 24,
  hurt: 24,
  ko: 90,
};

function getAnimSpeed(animState: AnimState): number {
  return STAND_FRAME_COUNT / ANIM_SPEED_DIVISOR[animState];
}

type Props = {
  side: "left" | "right";
  getAnimState: () => AnimState;
};

const STAND_CHAR: Record<"left" | "right", StandCharName> = {
  left: "star-platinum",
  right: "the-world",
};

export function Stand({ side, getAnimState }: Props) {
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
  const punchPlayCount = useRef(0);

  useEffect(() => {
    loadStandSprite(STAND_CHAR[side]).then(setAllTextures);
  }, [side]);

  useEffect(() => {
    const onResize = () =>
      setSize({ width: window.innerWidth, height: window.innerHeight });
    window.addEventListener("resize", onResize);
    return () => window.removeEventListener("resize", onResize);
  }, []);

  const handleRef = useCallback((node: AnimatedSprite | null) => {
    spriteRef.current = node;
    if (node) node.gotoAndPlay(0);
  }, []);

  useTick(() => {
    const sprite = spriteRef.current;
    if (!sprite || !allTextures) return;

    const animState = getAnimState();
    if (animState === prevAnimState.current) return;
    prevAnimState.current = animState;

    sprite.textures = allTextures[animState];
    sprite.animationSpeed = getAnimSpeed(animState);

    if (animState === "ko") {
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
    } else if (animState === "punch") {
      sprite.loop = false;
      sprite.animationSpeed = getAnimSpeed("punch") * 2;
      punchPlayCount.current = 0;
      sprite.onComplete = () => {
        punchPlayCount.current += 1;
        if (punchPlayCount.current < 2) {
          spriteRef.current?.gotoAndPlay(0);
        } else {
          sprite.onComplete = undefined;
        }
      };
      sprite.gotoAndPlay(0);
    } else {
      sprite.loop = false;
      sprite.onComplete = undefined;
      sprite.gotoAndPlay(0);
    }
  });

  if (!allTextures) return null;

  // スタンドは中央寄り・ファイターより上方に配置
  const x = side === "left" ? size.width * 0.44 : size.width * 0.56;
  const y = size.height * 0.75;
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
