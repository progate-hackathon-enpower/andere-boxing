import * as $protobuf from "protobufjs";
import Long = require("long");
/** Namespace andere_boxing. */
export namespace andere_boxing {
  /** Properties of a NetworkEvent. */
  interface INetworkEvent {
    /** NetworkEvent roomId */
    roomId?: string | null;

    /** NetworkEvent userId */
    userId?: string | null;

    /** NetworkEvent timestamp */
    timestamp?: number | Long | null;

    /** NetworkEvent userAction */
    userAction?: andere_boxing.UserAction | null;

    /** NetworkEvent roomAction */
    roomAction?: andere_boxing.RoomAction | null;
  }

  /** Represents a NetworkEvent. */
  class NetworkEvent implements INetworkEvent {
    /**
     * Constructs a new NetworkEvent.
     * @param [properties] Properties to set
     */
    constructor(properties?: andere_boxing.INetworkEvent);

    /** NetworkEvent roomId. */
    public roomId: string;

    /** NetworkEvent userId. */
    public userId: string;

    /** NetworkEvent timestamp. */
    public timestamp: number | Long;

    /** NetworkEvent userAction. */
    public userAction?: andere_boxing.UserAction | null;

    /** NetworkEvent roomAction. */
    public roomAction?: andere_boxing.RoomAction | null;

    /** NetworkEvent event. */
    public event?: "userAction" | "roomAction";

    /**
     * Creates a new NetworkEvent instance using the specified properties.
     * @param [properties] Properties to set
     * @returns NetworkEvent instance
     */
    public static create(
      properties?: andere_boxing.INetworkEvent,
    ): andere_boxing.NetworkEvent;

    /**
     * Encodes the specified NetworkEvent message. Does not implicitly {@link andere_boxing.NetworkEvent.verify|verify} messages.
     * @param message NetworkEvent message or plain object to encode
     * @param [writer] Writer to encode to
     * @returns Writer
     */
    public static encode(
      message: andere_boxing.INetworkEvent,
      writer?: $protobuf.Writer,
    ): $protobuf.Writer;

    /**
     * Encodes the specified NetworkEvent message, length delimited. Does not implicitly {@link andere_boxing.NetworkEvent.verify|verify} messages.
     * @param message NetworkEvent message or plain object to encode
     * @param [writer] Writer to encode to
     * @returns Writer
     */
    public static encodeDelimited(
      message: andere_boxing.INetworkEvent,
      writer?: $protobuf.Writer,
    ): $protobuf.Writer;

    /**
     * Decodes a NetworkEvent message from the specified reader or buffer.
     * @param reader Reader or buffer to decode from
     * @param [length] Message length if known beforehand
     * @returns NetworkEvent
     * @throws {Error} If the payload is not a reader or valid buffer
     * @throws {$protobuf.util.ProtocolError} If required fields are missing
     */
    public static decode(
      reader: $protobuf.Reader | Uint8Array,
      length?: number,
    ): andere_boxing.NetworkEvent;

    /**
     * Decodes a NetworkEvent message from the specified reader or buffer, length delimited.
     * @param reader Reader or buffer to decode from
     * @returns NetworkEvent
     * @throws {Error} If the payload is not a reader or valid buffer
     * @throws {$protobuf.util.ProtocolError} If required fields are missing
     */
    public static decodeDelimited(
      reader: $protobuf.Reader | Uint8Array,
    ): andere_boxing.NetworkEvent;

    /**
     * Verifies a NetworkEvent message.
     * @param message Plain object to verify
     * @returns `null` if valid, otherwise the reason why it is not
     */
    public static verify(message: { [k: string]: any }): string | null;

    /**
     * Creates a NetworkEvent message from a plain object. Also converts values to their respective internal types.
     * @param object Plain object
     * @returns NetworkEvent
     */
    public static fromObject(object: {
      [k: string]: any;
    }): andere_boxing.NetworkEvent;

    /**
     * Creates a plain object from a NetworkEvent message. Also converts values to other types if specified.
     * @param message NetworkEvent
     * @param [options] Conversion options
     * @returns Plain object
     */
    public static toObject(
      message: andere_boxing.NetworkEvent,
      options?: $protobuf.IConversionOptions,
    ): { [k: string]: any };

    /**
     * Converts this NetworkEvent to JSON.
     * @returns JSON object
     */
    public toJSON(): { [k: string]: any };

    /**
     * Gets the default type url for NetworkEvent
     * @param [typeUrlPrefix] your custom typeUrlPrefix(default "type.googleapis.com")
     * @returns The default type url
     */
    public static getTypeUrl(typeUrlPrefix?: string): string;
  }

  /** UserAction enum. */
  enum UserAction {
    USER_ACTION_UNSPECIFIED = 0,
    USER_ACTION_PUNCH = 1,
    USER_ACTION_DEFEND = 2,
  }

  /** RoomAction enum. */
  enum RoomAction {
    ROOM_ACTION_UNSPECIFIED = 0,
    ROOM_ACTION_CREATE = 1,
    ROOM_ACTION_START = 2,
    ROOM_ACTION_END = 3,
    ROOM_ACTION_DELETE = 4,
    ROOM_ACTION_JOIN = 5,
    ROOM_ACTION_LEAVE = 6,
  }
}
