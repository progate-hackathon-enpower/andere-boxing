import { useEffect, useRef } from "react";
import { andere_boxing } from "../generated/event_pb";
import type { PlayerAction } from "../game/types";

/**
 * キーボードで sync-server からの入力をシミュレートするフック。
 *
 * キーマップ:
 *   左プレイヤー (Player 0): a = punch / s = defend
 *   右プレイヤー (Player 1): k = punch / l = defend
 *
 * sync-server 導入時は、同じ PlayerAction (UserAction | null) を返す別フックに差し替えるだけでよい。
 */

const { UserAction } = andere_boxing;

type KeyMap = {
  punch: string;
  defend: string;
};

const KEY_MAP: [KeyMap, KeyMap] = [
  { punch: "a", defend: "s" }, // 左プレイヤー
  { punch: "k", defend: "l" }, // 右プレイヤー
];

export function useKeyboard() {
  const justPressedRef = useRef<Set<string>>(new Set());

  useEffect(() => {
    const onKeyDown = (e: KeyboardEvent) => {
      justPressedRef.current.add(e.key.toLowerCase());
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, []);

  const getAction = (playerIndex: 0 | 1): PlayerAction => {
    const keys = KEY_MAP[playerIndex];
    const justPressed = justPressedRef.current;

    if (justPressed.has(keys.punch)) return UserAction.USER_ACTION_PUNCH;
    if (justPressed.has(keys.defend)) return UserAction.USER_ACTION_DEFEND;
    return null;
  };

  /** Ticker の末尾で呼び出し、1フレーム分の入力をリセットする */
  const flushActions = () => {
    justPressedRef.current.clear();
  };

  return { getAction, flushActions };
}
