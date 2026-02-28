import { extend } from "@pixi/react";
import { Graphics } from "pixi.js";
import type { AnimState } from "../../game/types";

extend({ Graphics });

type Props = {
  side: "left" | "right";
  animState: AnimState;
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

export function Fighter({ side, animState }: Props) {
  const x =
    side === "left" ? window.innerWidth * 0.25 : window.innerWidth * 0.75;
  const y = window.innerHeight * 0.85;

  return (
    <pixiGraphics
      draw={(g: Graphics) => {
        g.clear();
        g.rect(0, 0, FIGHTER_WIDTH, FIGHTER_HEIGHT);
        g.fill(ANIM_COLOR[animState]);
      }}
      x={x}
      y={y}
      pivot={{ x: FIGHTER_WIDTH / 2, y: FIGHTER_HEIGHT }}
      scale={{ x: side === "right" ? -1 : 1, y: 1 }}
    />
  );
}
