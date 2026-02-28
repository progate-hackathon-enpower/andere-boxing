import { Assets, Rectangle, Texture } from "pixi.js";
import type { AnimState } from "./types";

export type StandCharName = "star-platinum" | "the-world";

// 各スタンドのフレーム境界（グリッド線を実測して算出）
const SPRITE_SPECS: Record<
  StandCharName,
  { colX: number[]; colW: number[]; rowY: number[]; rowH: number[] }
> = {
  "star-platinum": {
    colX: [0, 168, 338, 509, 685],
    colW: [167, 169, 170, 175, 165],
    rowY: [0, 204, 413, 618, 821],
    rowH: [193, 198, 194, 192, 192], // 足元を 10px トリム
  },
  "the-world": {
    colX: [0, 140, 279, 416, 554],
    colW: [139, 138, 136, 137, 132],
    rowY: [0, 203, 408, 618, 817],
    rowH: [192, 194, 199, 188, 196], // 足元を 10px トリム
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
