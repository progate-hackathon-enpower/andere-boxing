import { Assets, Rectangle, Texture } from "pixi.js";
import type { AnimState } from "./types";

// スプライトシート: 851×1024 px、5列×5行
// グリッド線位置（x=170,340,511,681 / y=204,409,614,819）を実測して算出
const COL_X = [0, 171, 341, 512, 682]; // 各列の開始 x
const COL_W = [170, 169, 170, 169, 169]; // 各列の幅
const ROW_Y = [0, 205, 410, 615, 820]; // 各行の開始 y
const ROW_H = 204; // 全行で共通の高さ

/** 各 AnimState のコマ数（全状態で共通）*/
export const FRAME_COUNT = COL_X.length;

const ANIM_ROW: Record<AnimState, number> = {
  idle: 0,
  punch: 1,
  defend: 2,
  hurt: 3,
  ko: 4,
};

function buildFrames(texture: Texture): Record<AnimState, Texture[]> {
  const source = texture.source;
  const result = {} as Record<AnimState, Texture[]>;
  for (const state of Object.keys(ANIM_ROW) as AnimState[]) {
    const row = ANIM_ROW[state];
    result[state] = COL_X.map(
      (x, col) =>
        new Texture({
          source,
          frame: new Rectangle(x, ROW_Y[row], COL_W[col], ROW_H),
        }),
    );
  }
  return result;
}

type CharName = "jotaro" | "dio";

// モジュールスコープのキャッシュ（同一キャラのロードは一度だけ）
const cache = new Map<CharName, Promise<Record<AnimState, Texture[]>>>();

export function loadFighterSprite(
  char: CharName,
): Promise<Record<AnimState, Texture[]>> {
  if (!cache.has(char)) {
    cache.set(
      char,
      Assets.load<Texture>(`/assets/${char}.png`).then(buildFrames),
    );
  }
  return cache.get(char)!;
}
