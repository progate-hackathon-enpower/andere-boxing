import { useEffect, useState } from "react";
import { andere_boxing } from "../generated/event_pb";
import { getGameTransport } from "../libs/gameTransport";
import { useGameState } from "../contexts/GameContext";

const { RoomAction } = andere_boxing;

/**
 * sync-server からブロードキャストされる RoomAction (JOIN/LEAVE) を受信し、
 * ルーム内のプレイヤーリストを管理するフック。
 *
 * playerCountRef（GameContext）も同期的に更新するため、
 * Stand コンポーネントが useTick 内から参照できる。
 *
 * Web 側は表示専用。JOIN/LEAVE イベントの送信はモバイル側が行う。
 */
export function useRoomConnection() {
  const { playerCountRef } = useGameState();
  const [players, setPlayers] = useState<string[]>([]);

  useEffect(() => {
    const transport = getGameTransport();
    const handler = (event: andere_boxing.NetworkEvent) => {
      if (event.event !== "roomAction") return;

      if (event.roomAction === RoomAction.ROOM_ACTION_JOIN) {
        setPlayers((prev) => {
          if (prev.includes(event.userId)) return prev;
          const next = [...prev, event.userId];
          playerCountRef.current = next.length;
          return next;
        });
      } else if (event.roomAction === RoomAction.ROOM_ACTION_LEAVE) {
        setPlayers((prev) => {
          const next = prev.filter((id) => id !== event.userId);
          playerCountRef.current = next.length;
          return next;
        });
      }
    };

    transport.on("event", handler);
    return () => {
      transport.off("event", handler);
    };
  }, [playerCountRef]);

  return { players, playerCount: players.length };
}
