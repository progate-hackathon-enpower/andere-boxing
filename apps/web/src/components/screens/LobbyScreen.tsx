import { useRoomConnection } from "../../hooks/useRoomConnection";

type LobbyScreenProps = {
  roomId: string;
  onStart: () => void;
};

export function LobbyScreen({ roomId, onStart }: LobbyScreenProps) {
  const { playerCount } = useRoomConnection();

  return (
    <div className="flex h-full flex-col items-center justify-center">
      <h2 className="pixel-title mb-4 text-3xl text-white">WAITING...</h2>
      <p className="pixel-text mb-4 text-2xl font-bold text-white/80">
        ROOM: {roomId}
      </p>
      <p className="pixel-text mb-12 text-white/80">
        PLAYERS: {playerCount} / 2
      </p>
      <button
        onClick={onStart}
        disabled={playerCount < 2}
        className="pixel-btn pixel-btn-green text-lg disabled:opacity-50"
      >
        FIGHT!!
      </button>
    </div>
  );
}
