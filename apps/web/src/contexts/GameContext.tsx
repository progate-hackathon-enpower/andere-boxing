import { createContext, useContext, useState, ReactNode } from "react";

interface GameContextType {
  resetKey: number;
  reset: () => void;
}

const GameContext = createContext<GameContextType | undefined>(undefined);

export function GameProvider({ children }: { children: ReactNode }) {
  const [resetKey, setResetKey] = useState(0);

  const reset = () => {
    setResetKey((prev) => prev + 1);
  };

  return (
    <GameContext.Provider value={{ resetKey, reset }}>
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
