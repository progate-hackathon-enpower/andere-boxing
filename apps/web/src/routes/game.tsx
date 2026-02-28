import { createFileRoute } from "@tanstack/react-router";
import { useEffect } from "react";
import { HUD } from "../components/game/HUD";
import { useGameState } from "../contexts/GameContext";

export const Route = createFileRoute("/game")({
  component: GameScreen,
});

function GameScreen() {
  const { reset } = useGameState();

  // /game に入るたびにゲームをリセットし、再戦を可能にする
  useEffect(() => {
    reset();
  }, [reset]);

  return <HUD />;
}
