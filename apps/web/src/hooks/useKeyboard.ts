import { useCallback, useEffect, useRef } from "react";
import { andere_boxing } from "../generated/event_pb";
import { getGameTransport } from "../libs/gameTransport";
import type { PlayerAction } from "../game/types";

/**
 * キーボード入力を NetworkEvent として sync-server 経由で送受信するフック。
 *
 * キーマップ:
 *   左プレイヤー (Player 0): a = punch / s = defend
 *   右プレイヤー (Player 1): k = punch / l = defend
 *
 * キー押下 → GameTransport.send() → sync-server ブロードキャスト → 受信 → getAction()
 */

const { UserAction } = andere_boxing;

type KeyBinding = { playerIndex: 0 | 1; action: andere_boxing.UserAction };

const KEY_BINDINGS: Record<string, KeyBinding> = {
  a: { playerIndex: 0, action: UserAction.USER_ACTION_PUNCH },
  s: { playerIndex: 0, action: UserAction.USER_ACTION_DEFEND },
  k: { playerIndex: 1, action: UserAction.USER_ACTION_PUNCH },
  l: { playerIndex: 1, action: UserAction.USER_ACTION_DEFEND },
};

export function useKeyboard(roomId = "") {
  const pendingRef = useRef<[PlayerAction, PlayerAction]>([null, null]);

  // 受信: NetworkEvent → フレームバッファに積む
  useEffect(() => {
    const transport = getGameTransport();
    const handler = (event: andere_boxing.NetworkEvent) => {
      if (event.event !== "userAction") return;
      if (event.userId === "player-0")
        pendingRef.current[0] = event.userAction ?? null;
      else if (event.userId === "player-1")
        pendingRef.current[1] = event.userAction ?? null;
    };
    transport.on("event", handler);
    return () => {
      transport.off("event", handler);
    };
  }, []);

  // 送信: キー押下 → NetworkEvent
  useEffect(() => {
    const transport = getGameTransport();
    const onKeyDown = (e: KeyboardEvent) => {
      const binding = KEY_BINDINGS[e.key.toLowerCase()];
      if (!binding) return;
      transport.emit(
        "event",
        andere_boxing.NetworkEvent.create({
          roomId,
          userId: `player-${binding.playerIndex}`,
          timestamp: Date.now(),
          userAction: binding.action,
        }),
      );
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [roomId]);

  const getAction = useCallback((playerIndex: 0 | 1): PlayerAction => {
    return pendingRef.current[playerIndex];
  }, []);

  /** Ticker の末尾で呼び出し、1フレーム分の入力をリセットする */
  const flushActions = useCallback(() => {
    pendingRef.current = [null, null];
  }, []);

  return { getAction, flushActions };
}
