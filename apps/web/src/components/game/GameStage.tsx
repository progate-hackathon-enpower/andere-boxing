import { Application } from "@pixi/react";
import { Background } from "./Background";

export function GameStage() {
  return (
    <Application resizeTo={window}>
      <Background />
    </Application>
  );
}
