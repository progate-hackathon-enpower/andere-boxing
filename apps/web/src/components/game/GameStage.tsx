import { Application } from "@pixi/react";
import { lazy, Suspense } from "react";
import { Background } from "./Background";
import { useGameState } from "../../contexts/GameContext";

/**
 * GameContent は useKeyboard → event_pb → protobufjs という CJS 依存チェーンを持つ。
 * SSR のモジュールグラフに入れないよう React.lazy で遅延ロードする。
 * GameStage 自体は __root.tsx から静的インポートされるが、
 * GameContent は mounted=true（クライアントのみ）で初めてレンダリングされるため
 * SSR 上で動的インポートは実行されない。
 */
const GameContent = lazy(() => import("./GameContent"));

export function GameStage() {
  const { resetKey } = useGameState();

  return (
    <Application resizeTo={window}>
      <Background />
      <Suspense fallback={null}>
        {/* resetKey が変わるたびに GameContent が再マウントされ、状態がリセットされる */}
        <GameContent key={resetKey} />
      </Suspense>
    </Application>
  );
}
