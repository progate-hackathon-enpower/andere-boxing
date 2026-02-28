import EventEmitter from "eventemitter3";
import { andere_boxing } from "@/generated/event_pb";

let instance: EventEmitter<GameTransportEvents> | null = null;

export function getGameTransport() {
  if (!instance) {
    instance = new EventEmitter<GameTransportEvents>();
  }
  return instance;
}

type GameTransportEvents = {
  event: [andere_boxing.NetworkEvent];
};

class GameTransport extends EventEmitter<GameTransportEvents> {
  private transport: WebTransport | null = null;
  private writer: WritableStreamDefaultWriter<Uint8Array> | null = null;

  async connect(url: string) {
    if (this.transport) {
      throw new Error("Already connected");
    }

    this.transport = new WebTransport(url);
    await this.transport.ready;

    this.writer = this.transport.datagrams.writable.getWriter();
    this.readDatagrams();
  }

  async send(event: andere_boxing.NetworkEvent) {
    if (!this.writer) return;
    const encoded = andere_boxing.NetworkEvent.encode(event).finish();
    await this.writer.write(encoded);
  }

  private async readDatagrams() {
    if (!this.transport) return;

    const reader = this.transport.datagrams.readable.getReader();
    try {
      while (true) {
        const { value, done } = await reader.read();
        if (done) break;

        const event = andere_boxing.NetworkEvent.decode(value);
        this.emit("event", event);
      }
    } catch (e) {
      console.log("Error reading datagrams:", e);
    }
  }

  close() {
    if (!this.transport) return;

    this.writer?.releaseLock();
    this.writer = null;
    this.transport.close();
    this.transport = null;

    const event = andere_boxing.NetworkEvent.create({
      roomAction: andere_boxing.RoomAction.ROOM_ACTION_LEAVE,
    });

    this.emit("event", event);
  }
}

export default GameTransport;
