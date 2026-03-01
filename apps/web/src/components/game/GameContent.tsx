import { useCallback } from "react";
import { useKeyboard } from "../../hooks/useKeyboard";
import { useGameLoop } from "../../hooks/useGameLoop";
import { useGameState } from "../../contexts/GameContext";
import { Dogo } from "./Dogo";
import { Fighter } from "./Fighter";
import { Stand } from "./Stand";

/**
 * ゲームロジック層。useKeyboard → event_pb → protobufjs という依存チェーンを持つため、
 * GameStage から React.lazy で遅延ロードし SSR のモジュールグラフに入れない。
 */
export default function GameContent() {
  const { gameStateRef, playerCountRef } = useGameState();
  const { getAction, flushActions } = useKeyboard();
  useGameLoop({ getAction, flushActions, stateRef: gameStateRef });

  const getLeftAnimState = useCallback(
    () => gameStateRef.current?.players[0].animState ?? "idle",
    [gameStateRef],
  );
  const getRightAnimState = useCallback(
    () => gameStateRef.current?.players[1].animState ?? "idle",
    [gameStateRef],
  );

  // star-platinum: 1人目が JOIN で表示
  const getLeftVisible = useCallback(
    () => playerCountRef.current >= 1,
    [playerCountRef],
  );
  // the-world: 2人目が JOIN で表示
  const getRightVisible = useCallback(
    () => playerCountRef.current >= 2,
    [playerCountRef],
  );

  return (
    <>
      {/* Dogo → Fighter → Stand の順で描画（Dogo が最背後、Stand が最前面）*/}
      <Dogo side="left" getAnimState={getLeftAnimState} />
      <Dogo side="right" getAnimState={getRightAnimState} />
      <Fighter side="left" getAnimState={getLeftAnimState} />
      <Fighter side="right" getAnimState={getRightAnimState} />
      <Stand
        side="left"
        getAnimState={getLeftAnimState}
        getVisible={getLeftVisible}
      />
      <Stand
        side="right"
        getAnimState={getRightAnimState}
        getVisible={getRightVisible}
      />
    </>
  );
}
