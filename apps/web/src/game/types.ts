import { andere_boxing } from "../generated/event_pb";

export { andere_boxing };

export type AnimState = "idle" | "punch" | "defend" | "hurt" | "ko";

export type PlayerState = {
  hp: number;
  /** 最大体力 */
  maxHp: number;
  /**
   * 精神力 (スタミナ)。
   * パンチ・ディフェンド使用時に消費し、0 になるとアクション不能になる。
   * 消費量・回復量・上限は STAMINA_CONFIG で調整する。
   */
  stamina: number;
  animState: AnimState;
  /** アニメーションの経過フレーム数 */
  animFrame: number;
};

export type GamePhase = "fighting" | "result";

export type GameState = {
  players: [PlayerState, PlayerState];
  /** 残り秒数 */
  timer: number;
  phase: GamePhase;
};

/**
 * プレイヤーのアクション。proto の UserAction をそのまま使用する。
 * キーボード (useKeyboard) と sync-server どちらの入力層でも同じ型を返す。
 *
 * - null: このフレームで入力なし
 * - USER_ACTION_UNSPECIFIED: sync-server から来る可能性がある。
 *   ゲームロジック側で null と同等に扱う。
 */
export type PlayerAction = andere_boxing.UserAction | null;
