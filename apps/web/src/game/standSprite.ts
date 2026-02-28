import { Assets, Rectangle, Texture } from "pixi.js";
import type { AnimState } from "./types";

export type StandCharName = "star-platinum" | "the-world";

// 各スタンドのフレーム境界（グリッド線を実測して算出）
const SPRITE_SPECS: Record<
  StandCharName,
  { colX: number[]; colW: number[]; rowY: number[]; rowH: number[] }
> = {
  "star-platinum": {
    colX: [0, 170, 340, 510, 680],
    colW: [170, 170, 170, 170, 171],
    rowY: [10, 236, 440, 639, 834],
    rowH: [205, 186, 189, 192, 190],
  },
  "the-world": {
    colX: [7, 142, 277, 412, 547],
    colW: [135, 135, 135, 135, 137],
    rowY: [29, 265, 455, 654, 874],
    rowH: [223, 188, 197, 193, 150],
  },
};

export const STAND_FRAME_COUNT = 5;

const ANIM_ROW: Record<AnimState, number> = {
  idle: 0,
  punch: 1,
  defend: 2,
  hurt: 3,
  ko: 4,
};

function buildFrames(
  texture: Texture,
  char: StandCharName,
): Record<AnimState, Texture[]> {
  const source = texture.source;
  const spec = SPRITE_SPECS[char];
  const result = {} as Record<AnimState, Texture[]>;
  for (const state of Object.keys(ANIM_ROW) as AnimState[]) {
    const row = ANIM_ROW[state];
    result[state] = spec.colX.map(
      (x, col) =>
        new Texture({
          source,
          frame: new Rectangle(
            x,
            spec.rowY[row],
            spec.colW[col],
            spec.rowH[row],
          ),
        }),
    );
  }
  return result;
}

const cache = new Map<StandCharName, Promise<Record<AnimState, Texture[]>>>();

export function loadStandSprite(
  char: StandCharName,
): Promise<Record<AnimState, Texture[]>> {
  if (!cache.has(char)) {
    cache.set(
      char,
      Assets.load<Texture>(`/assets/${char}.png`).then((tex) =>
        buildFrames(tex, char),
      ),
    );
  }
  return cache.get(char)!;
}
