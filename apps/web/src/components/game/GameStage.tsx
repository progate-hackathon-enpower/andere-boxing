import { Application } from "@pixi/react";
import { Background } from "./Background";
import { Fighter } from "./Fighter";

export function GameStage() {
  return (
    <Application resizeTo={window}>
      <Background />
      <Fighter side="left" animState="defend" />
      <Fighter side="right" animState="punch" />
    </Application>
  );
}
