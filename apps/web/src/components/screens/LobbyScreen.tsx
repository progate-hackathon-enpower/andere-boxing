type LobbyScreenProps = {
  roomId: string;
  onStart: () => void;
};

export function LobbyScreen({ roomId, onStart }: LobbyScreenProps) {
  return (
    <div className="flex h-full flex-col items-center justify-center">
      <h2 className="pixel-title mb-4 text-3xl text-white">WAITING...</h2>
      <p className="pixel-text mb-4 text-white/80">ROOM: {roomId}</p>
      <p className="pixel-text mb-12 text-white/80">LOOKING FOR OPPONENT...</p>
      <button onClick={onStart} className="pixel-btn pixel-btn-green text-lg">
        FIGHT!!
      </button>
    </div>
  );
}
