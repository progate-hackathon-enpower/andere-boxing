/** 体力・精神力の初期値と変化量。後から調整しやすいよう定数として切り出す */

export const GAME_CONFIG = {
  /** 試合時間 (秒) */
  roundDuration: 60,

  hp: {
    initial: 100,
    /** ガードなしでパンチを受けたときのダメージ */
    punchDamage: 20,
  },

  stamina: {
    initial: 100,
    max: 100,
    /** パンチ使用時の消費量 */
    punchCost: 15,
    /** ディフェンド使用時の消費量 */
    defendCost: 10,
    /** 毎フレームの自然回復量 (60fps 想定) */
    regenPerFrame: 0.2,
  },

  /** アニメーションの持続フレーム数 */
  animDuration: {
    punch: 20,
    defend: 15,
    hurt: 15,
    ko: 90,
  },
} as const;
