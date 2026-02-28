import { createFileRoute } from "@tanstack/react-router";
import { HUD } from "../components/game/HUD";

export const Route = createFileRoute("/game")({
  component: GameScreen,
});

function GameScreen() {
  return <HUD />;
}
