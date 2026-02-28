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
  const { gameStateRef } = useGameState();
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

  return (
    <>
      {/* Dogo → Fighter → Stand の順で描画（Dogo が最背後、Stand が最前面）*/}
      <Dogo side="left" getAnimState={getLeftAnimState} />
      <Dogo side="right" getAnimState={getRightAnimState} />
      <Fighter side="left" getAnimState={getLeftAnimState} />
      <Fighter side="right" getAnimState={getRightAnimState} />
      <Stand side="left" getAnimState={getLeftAnimState} />
      <Stand side="right" getAnimState={getRightAnimState} />
    </>
  );
}
