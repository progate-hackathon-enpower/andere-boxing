import { useState } from "react";
import { andere_boxing } from "../../generated/event_pb";
import { getGameTransport } from "../../libs/gameTransport";

const { UserAction, RoomAction } = andere_boxing;

const EVENT_TYPES = {
  userAction: {
    label: "UserAction",
    actions: [
      { label: "PUNCH", value: UserAction.USER_ACTION_PUNCH },
      { label: "DEFEND", value: UserAction.USER_ACTION_DEFEND },
    ],
  },
  roomAction: {
    label: "RoomAction",
    actions: [
      { label: "CREATE", value: RoomAction.ROOM_ACTION_CREATE },
      { label: "START", value: RoomAction.ROOM_ACTION_START },
      { label: "END", value: RoomAction.ROOM_ACTION_END },
      { label: "DELETE", value: RoomAction.ROOM_ACTION_DELETE },
      { label: "JOIN", value: RoomAction.ROOM_ACTION_JOIN },
      { label: "LEAVE", value: RoomAction.ROOM_ACTION_LEAVE },
    ],
  },
} as const;

type EventType = keyof typeof EVENT_TYPES;

/** コンポーネント外のヘルパー（Date.now 等の impure 呼び出しを含む） */
function fireEvent(
  eventType: EventType,
  actionValue: number,
  roomId: string,
  userId: string,
): string {
  const transport = getGameTransport();
  const payload =
    eventType === "userAction"
      ? { userAction: actionValue as andere_boxing.UserAction }
      : { roomAction: actionValue as andere_boxing.RoomAction };

  const event = andere_boxing.NetworkEvent.create({
    roomId,
    userId,
    timestamp: Date.now(),
    ...payload,
  });

  transport.emit("event", event);

  const actionLabel =
    EVENT_TYPES[eventType].actions.find((a) => a.value === actionValue)
      ?.label ?? String(actionValue);
  return `${new Date().toLocaleTimeString()} [${userId}] ${eventType}.${actionLabel}`;
}

export default function DebugEventPanel() {
  const [open, setOpen] = useState(false);
  const [eventType, setEventType] = useState<EventType>("roomAction");
  const [userId, setUserId] = useState("player-0");
  const [roomId, setRoomId] = useState("");
  const [log, setLog] = useState<string[]>([]);

  const emitEvent = (actionValue: number) => {
    const entry = fireEvent(eventType, actionValue, roomId, userId);
    setLog((prev) => [entry, ...prev].slice(0, 20));
  };

  if (!open) {
    return (
      <button
        onClick={() => setOpen(true)}
        className="fixed bottom-4 left-4 z-50 rounded bg-gray-800/90 px-3 py-1 font-mono text-xs text-green-400"
      >
        DEBUG
      </button>
    );
  }

  return (
    <div className="fixed bottom-4 left-4 z-50 flex w-72 flex-col gap-2 rounded-lg bg-gray-900/95 p-3 font-mono text-xs text-white shadow-lg">
      <div className="flex items-center justify-between">
        <span className="font-bold text-green-400">Event Emitter</span>
        <button
          onClick={() => setOpen(false)}
          className="text-gray-400 hover:text-white"
        >
          x
        </button>
      </div>

      {/* userId / roomId */}
      <div className="flex gap-2">
        <input
          value={userId}
          onChange={(e) => setUserId(e.target.value)}
          placeholder="userId"
          className="w-1/2 rounded bg-gray-800 px-2 py-1 text-white"
        />
        <input
          value={roomId}
          onChange={(e) => setRoomId(e.target.value)}
          placeholder="roomId"
          className="w-1/2 rounded bg-gray-800 px-2 py-1 text-white"
        />
      </div>

      {/* event type 切り替え */}
      <div className="flex gap-1">
        {(Object.keys(EVENT_TYPES) as EventType[]).map((type) => (
          <button
            key={type}
            onClick={() => setEventType(type)}
            className={`rounded px-2 py-1 ${
              eventType === type
                ? "bg-green-600 text-white"
                : "bg-gray-700 text-gray-300"
            }`}
          >
            {EVENT_TYPES[type].label}
          </button>
        ))}
      </div>

      {/* アクションボタン */}
      <div className="flex flex-wrap gap-1">
        {EVENT_TYPES[eventType].actions.map((action) => (
          <button
            key={action.label}
            onClick={() => emitEvent(action.value)}
            className="rounded bg-gray-700 px-2 py-1 hover:bg-gray-600"
          >
            {action.label}
          </button>
        ))}
      </div>

      {/* ログ */}
      {log.length > 0 && (
        <div className="max-h-32 overflow-y-auto border-t border-gray-700 pt-1 text-[10px] text-gray-400">
          {log.map((entry, i) => (
            <div key={i}>{entry}</div>
          ))}
        </div>
      )}
    </div>
  );
}
