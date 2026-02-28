import { useNavigate } from "@tanstack/react-router";
import { useCallback, useRef } from "react";
import { useTick } from "@pixi/react";
import { useKeyboard } from "../../hooks/useKeyboard";
import { useGameLoop } from "../../hooks/useGameLoop";
import { useGameState } from "../../contexts/GameContext";
import { Fighter } from "./Fighter";
import { Stand } from "./Stand";

/**
 * ゲームロジック層。useKeyboard → event_pb → protobufjs という依存チェーンを持つため、
 * GameStage から React.lazy で遅延ロードし SSR のモジュールグラフに入れない。
 */
export default function GameContent() {
  const navigate = useNavigate();
  const { getAction, flushActions } = useKeyboard();
  const gameStateRef = useGameLoop({ getAction, flushActions });
  const { gameStateRef: contextGameStateRef } = useGameState();
  const hasNavigatedRef = useRef(false);
  const getLeftAnimState = useCallback(
    () => gameStateRef.current.players[0].animState,
    [gameStateRef],
  );
  const getRightAnimState = useCallback(
    () => gameStateRef.current.players[1].animState,
    [gameStateRef],
  );

  useTick(() => {
    contextGameStateRef.current = gameStateRef.current;

    if (hasNavigatedRef.current) return;

    const state = gameStateRef.current;
    if (state.phase === "result") {
      hasNavigatedRef.current = true;
      navigate({ to: "/result" });
    }
  });

  return (
    <>
      {/* Fighter → Stand の順で描画（Stand がファイターより手前に表示される）*/}
      <Fighter side="left" getAnimState={getLeftAnimState} />
      <Fighter side="right" getAnimState={getRightAnimState} />
      <Stand side="left" getAnimState={getLeftAnimState} />
      <Stand side="right" getAnimState={getRightAnimState} />
    </>
  );
}
