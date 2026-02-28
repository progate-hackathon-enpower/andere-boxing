import { useNavigate } from "@tanstack/react-router";
import { useRef } from "react";
import { useTick } from "@pixi/react";
import { useKeyboard } from "../../hooks/useKeyboard";
import { useGameLoop } from "../../hooks/useGameLoop";
import { Fighter } from "./Fighter";

/**
 * ゲームロジック層。useKeyboard → event_pb → protobufjs という依存チェーンを持つため、
 * GameStage から React.lazy で遅延ロードし SSR のモジュールグラフに入れない。
 */
export default function GameContent() {
  const navigate = useNavigate();
  const { getAction, flushActions } = useKeyboard();
  const gameStateRef = useGameLoop({ getAction, flushActions });
  const hasNavigatedRef = useRef(false);

  useTick(() => {
    if (hasNavigatedRef.current) return;

    const state = gameStateRef.current;
    if (state.phase === "result") {
      hasNavigatedRef.current = true;
      navigate({ to: "/result" });
    }
  });

  return (
    <>
      <Fighter
        side="left"
        getAnimState={() => gameStateRef.current.players[0].animState}
      />
      <Fighter
        side="right"
        getAnimState={() => gameStateRef.current.players[1].animState}
      />
    </>
  );
}
