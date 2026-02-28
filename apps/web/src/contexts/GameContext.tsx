import {
  createContext,
  useCallback,
  useContext,
  useRef,
  useState,
  ReactNode,
} from "react";
import type { GameState } from "../game/types";

interface GameContextType {
  resetKey: number;
  reset: () => void;
  gameStateRef: React.RefObject<GameState | null>;
}

const GameContext = createContext<GameContextType | undefined>(undefined);

export function GameProvider({ children }: { children: ReactNode }) {
  const [resetKey, setResetKey] = useState(0);
  const gameStateRef = useRef<GameState | null>(null);

  const reset = useCallback(() => {
    gameStateRef.current = null;
    setResetKey((prev) => prev + 1);
  }, []);

  return (
    <GameContext.Provider value={{ resetKey, reset, gameStateRef }}>
      {children}
    </GameContext.Provider>
  );
}

export function useGameState() {
  const context = useContext(GameContext);
  if (context === undefined) {
    throw new Error("useGameState must be used within GameProvider");
  }
  return context;
}
