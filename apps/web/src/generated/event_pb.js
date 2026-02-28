/*eslint-disable block-scoped-var, id-length, no-control-regex, no-magic-numbers, no-prototype-builtins, no-redeclare, no-shadow, no-var, sort-vars*/
import * as $protobuf from "protobufjs/minimal";

// Common aliases
const $Reader = $protobuf.Reader, $Writer = $protobuf.Writer, $util = $protobuf.util;

// Exported root namespace
const $root = $protobuf.roots["default"] || ($protobuf.roots["default"] = {});

export const andere_boxing = $root.andere_boxing = (() => {

    /**
     * Namespace andere_boxing.
     * @exports andere_boxing
     * @namespace
     */
    const andere_boxing = {};

    andere_boxing.NetworkEvent = (function() {

        /**
         * Properties of a NetworkEvent.
         * @memberof andere_boxing
         * @interface INetworkEvent
         * @property {string|null} [roomId] NetworkEvent roomId
         * @property {string|null} [userId] NetworkEvent userId
         * @property {number|Long|null} [timestamp] NetworkEvent timestamp
         * @property {andere_boxing.UserAction|null} [userAction] NetworkEvent userAction
         * @property {andere_boxing.RoomAction|null} [roomAction] NetworkEvent roomAction
         */

        /**
         * Constructs a new NetworkEvent.
         * @memberof andere_boxing
         * @classdesc Represents a NetworkEvent.
         * @implements INetworkEvent
         * @constructor
         * @param {andere_boxing.INetworkEvent=} [properties] Properties to set
         */
        function NetworkEvent(properties) {
            if (properties)
                for (let keys = Object.keys(properties), i = 0; i < keys.length; ++i)
                    if (properties[keys[i]] != null)
                        this[keys[i]] = properties[keys[i]];
        }

        /**
         * NetworkEvent roomId.
         * @member {string} roomId
         * @memberof andere_boxing.NetworkEvent
         * @instance
         */
        NetworkEvent.prototype.roomId = "";

        /**
         * NetworkEvent userId.
         * @member {string} userId
         * @memberof andere_boxing.NetworkEvent
         * @instance
         */
        NetworkEvent.prototype.userId = "";

        /**
         * NetworkEvent timestamp.
         * @member {number|Long} timestamp
         * @memberof andere_boxing.NetworkEvent
         * @instance
         */
        NetworkEvent.prototype.timestamp = $util.Long ? $util.Long.fromBits(0,0,false) : 0;

        /**
         * NetworkEvent userAction.
         * @member {andere_boxing.UserAction|null|undefined} userAction
         * @memberof andere_boxing.NetworkEvent
         * @instance
         */
        NetworkEvent.prototype.userAction = null;

        /**
         * NetworkEvent roomAction.
         * @member {andere_boxing.RoomAction|null|undefined} roomAction
         * @memberof andere_boxing.NetworkEvent
         * @instance
         */
        NetworkEvent.prototype.roomAction = null;

        // OneOf field names bound to virtual getters and setters
        let $oneOfFields;

        /**
         * NetworkEvent event.
         * @member {"userAction"|"roomAction"|undefined} event
         * @memberof andere_boxing.NetworkEvent
         * @instance
         */
        Object.defineProperty(NetworkEvent.prototype, "event", {
            get: $util.oneOfGetter($oneOfFields = ["userAction", "roomAction"]),
            set: $util.oneOfSetter($oneOfFields)
        });

        /**
         * Creates a new NetworkEvent instance using the specified properties.
         * @function create
         * @memberof andere_boxing.NetworkEvent
         * @static
         * @param {andere_boxing.INetworkEvent=} [properties] Properties to set
         * @returns {andere_boxing.NetworkEvent} NetworkEvent instance
         */
        NetworkEvent.create = function create(properties) {
            return new NetworkEvent(properties);
        };

        /**
         * Encodes the specified NetworkEvent message. Does not implicitly {@link andere_boxing.NetworkEvent.verify|verify} messages.
         * @function encode
         * @memberof andere_boxing.NetworkEvent
         * @static
         * @param {andere_boxing.INetworkEvent} message NetworkEvent message or plain object to encode
         * @param {$protobuf.Writer} [writer] Writer to encode to
         * @returns {$protobuf.Writer} Writer
         */
        NetworkEvent.encode = function encode(message, writer) {
            if (!writer)
                writer = $Writer.create();
            if (message.roomId != null && Object.hasOwnProperty.call(message, "roomId"))
                writer.uint32(/* id 1, wireType 2 =*/10).string(message.roomId);
            if (message.userId != null && Object.hasOwnProperty.call(message, "userId"))
                writer.uint32(/* id 2, wireType 2 =*/18).string(message.userId);
            if (message.timestamp != null && Object.hasOwnProperty.call(message, "timestamp"))
                writer.uint32(/* id 3, wireType 0 =*/24).int64(message.timestamp);
            if (message.userAction != null && Object.hasOwnProperty.call(message, "userAction"))
                writer.uint32(/* id 4, wireType 0 =*/32).int32(message.userAction);
            if (message.roomAction != null && Object.hasOwnProperty.call(message, "roomAction"))
                writer.uint32(/* id 5, wireType 0 =*/40).int32(message.roomAction);
            return writer;
        };

        /**
         * Encodes the specified NetworkEvent message, length delimited. Does not implicitly {@link andere_boxing.NetworkEvent.verify|verify} messages.
         * @function encodeDelimited
         * @memberof andere_boxing.NetworkEvent
         * @static
         * @param {andere_boxing.INetworkEvent} message NetworkEvent message or plain object to encode
         * @param {$protobuf.Writer} [writer] Writer to encode to
         * @returns {$protobuf.Writer} Writer
         */
        NetworkEvent.encodeDelimited = function encodeDelimited(message, writer) {
            return this.encode(message, writer).ldelim();
        };

        /**
         * Decodes a NetworkEvent message from the specified reader or buffer.
         * @function decode
         * @memberof andere_boxing.NetworkEvent
         * @static
         * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
         * @param {number} [length] Message length if known beforehand
         * @returns {andere_boxing.NetworkEvent} NetworkEvent
         * @throws {Error} If the payload is not a reader or valid buffer
         * @throws {$protobuf.util.ProtocolError} If required fields are missing
         */
        NetworkEvent.decode = function decode(reader, length, error) {
            if (!(reader instanceof $Reader))
                reader = $Reader.create(reader);
            let end = length === undefined ? reader.len : reader.pos + length, message = new $root.andere_boxing.NetworkEvent();
            while (reader.pos < end) {
                let tag = reader.uint32();
                if (tag === error)
                    break;
                switch (tag >>> 3) {
                case 1: {
                        message.roomId = reader.string();
                        break;
                    }
                case 2: {
                        message.userId = reader.string();
                        break;
                    }
                case 3: {
                        message.timestamp = reader.int64();
                        break;
                    }
                case 4: {
                        message.userAction = reader.int32();
                        break;
                    }
                case 5: {
                        message.roomAction = reader.int32();
                        break;
                    }
                default:
                    reader.skipType(tag & 7);
                    break;
                }
            }
            return message;
        };

        /**
         * Decodes a NetworkEvent message from the specified reader or buffer, length delimited.
         * @function decodeDelimited
         * @memberof andere_boxing.NetworkEvent
         * @static
         * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
         * @returns {andere_boxing.NetworkEvent} NetworkEvent
         * @throws {Error} If the payload is not a reader or valid buffer
         * @throws {$protobuf.util.ProtocolError} If required fields are missing
         */
        NetworkEvent.decodeDelimited = function decodeDelimited(reader) {
            if (!(reader instanceof $Reader))
                reader = new $Reader(reader);
            return this.decode(reader, reader.uint32());
        };

        /**
         * Verifies a NetworkEvent message.
         * @function verify
         * @memberof andere_boxing.NetworkEvent
         * @static
         * @param {Object.<string,*>} message Plain object to verify
         * @returns {string|null} `null` if valid, otherwise the reason why it is not
         */
        NetworkEvent.verify = function verify(message) {
            if (typeof message !== "object" || message === null)
                return "object expected";
            let properties = {};
            if (message.roomId != null && message.hasOwnProperty("roomId"))
                if (!$util.isString(message.roomId))
                    return "roomId: string expected";
            if (message.userId != null && message.hasOwnProperty("userId"))
                if (!$util.isString(message.userId))
                    return "userId: string expected";
            if (message.timestamp != null && message.hasOwnProperty("timestamp"))
                if (!$util.isInteger(message.timestamp) && !(message.timestamp && $util.isInteger(message.timestamp.low) && $util.isInteger(message.timestamp.high)))
                    return "timestamp: integer|Long expected";
            if (message.userAction != null && message.hasOwnProperty("userAction")) {
                properties.event = 1;
                switch (message.userAction) {
                default:
                    return "userAction: enum value expected";
                case 0:
                case 1:
                case 2:
                    break;
                }
            }
            if (message.roomAction != null && message.hasOwnProperty("roomAction")) {
                if (properties.event === 1)
                    return "event: multiple values";
                properties.event = 1;
                switch (message.roomAction) {
                default:
                    return "roomAction: enum value expected";
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                    break;
                }
            }
            return null;
        };

        /**
         * Creates a NetworkEvent message from a plain object. Also converts values to their respective internal types.
         * @function fromObject
         * @memberof andere_boxing.NetworkEvent
         * @static
         * @param {Object.<string,*>} object Plain object
         * @returns {andere_boxing.NetworkEvent} NetworkEvent
         */
        NetworkEvent.fromObject = function fromObject(object) {
            if (object instanceof $root.andere_boxing.NetworkEvent)
                return object;
            let message = new $root.andere_boxing.NetworkEvent();
            if (object.roomId != null)
                message.roomId = String(object.roomId);
            if (object.userId != null)
                message.userId = String(object.userId);
            if (object.timestamp != null)
                if ($util.Long)
                    (message.timestamp = $util.Long.fromValue(object.timestamp)).unsigned = false;
                else if (typeof object.timestamp === "string")
                    message.timestamp = parseInt(object.timestamp, 10);
                else if (typeof object.timestamp === "number")
                    message.timestamp = object.timestamp;
                else if (typeof object.timestamp === "object")
                    message.timestamp = new $util.LongBits(object.timestamp.low >>> 0, object.timestamp.high >>> 0).toNumber();
            switch (object.userAction) {
            default:
                if (typeof object.userAction === "number") {
                    message.userAction = object.userAction;
                    break;
                }
                break;
            case "USER_ACTION_UNSPECIFIED":
            case 0:
                message.userAction = 0;
                break;
            case "USER_ACTION_PUNCH":
            case 1:
                message.userAction = 1;
                break;
            case "USER_ACTION_DEFEND":
            case 2:
                message.userAction = 2;
                break;
            }
            switch (object.roomAction) {
            default:
                if (typeof object.roomAction === "number") {
                    message.roomAction = object.roomAction;
                    break;
                }
                break;
            case "ROOM_ACTION_UNSPECIFIED":
            case 0:
                message.roomAction = 0;
                break;
            case "ROOM_ACTION_CREATE":
            case 1:
                message.roomAction = 1;
                break;
            case "ROOM_ACTION_START":
            case 2:
                message.roomAction = 2;
                break;
            case "ROOM_ACTION_END":
            case 3:
                message.roomAction = 3;
                break;
            case "ROOM_ACTION_DELETE":
            case 4:
                message.roomAction = 4;
                break;
            case "ROOM_ACTION_JOIN":
            case 5:
                message.roomAction = 5;
                break;
            case "ROOM_ACTION_LEAVE":
            case 6:
                message.roomAction = 6;
                break;
            }
            return message;
        };

        /**
         * Creates a plain object from a NetworkEvent message. Also converts values to other types if specified.
         * @function toObject
         * @memberof andere_boxing.NetworkEvent
         * @static
         * @param {andere_boxing.NetworkEvent} message NetworkEvent
         * @param {$protobuf.IConversionOptions} [options] Conversion options
         * @returns {Object.<string,*>} Plain object
         */
        NetworkEvent.toObject = function toObject(message, options) {
            if (!options)
                options = {};
            let object = {};
            if (options.defaults) {
                object.roomId = "";
                object.userId = "";
                if ($util.Long) {
                    let long = new $util.Long(0, 0, false);
                    object.timestamp = options.longs === String ? long.toString() : options.longs === Number ? long.toNumber() : long;
                } else
                    object.timestamp = options.longs === String ? "0" : 0;
            }
            if (message.roomId != null && message.hasOwnProperty("roomId"))
                object.roomId = message.roomId;
            if (message.userId != null && message.hasOwnProperty("userId"))
                object.userId = message.userId;
            if (message.timestamp != null && message.hasOwnProperty("timestamp"))
                if (typeof message.timestamp === "number")
                    object.timestamp = options.longs === String ? String(message.timestamp) : message.timestamp;
                else
                    object.timestamp = options.longs === String ? $util.Long.prototype.toString.call(message.timestamp) : options.longs === Number ? new $util.LongBits(message.timestamp.low >>> 0, message.timestamp.high >>> 0).toNumber() : message.timestamp;
            if (message.userAction != null && message.hasOwnProperty("userAction")) {
                object.userAction = options.enums === String ? $root.andere_boxing.UserAction[message.userAction] === undefined ? message.userAction : $root.andere_boxing.UserAction[message.userAction] : message.userAction;
                if (options.oneofs)
                    object.event = "userAction";
            }
            if (message.roomAction != null && message.hasOwnProperty("roomAction")) {
                object.roomAction = options.enums === String ? $root.andere_boxing.RoomAction[message.roomAction] === undefined ? message.roomAction : $root.andere_boxing.RoomAction[message.roomAction] : message.roomAction;
                if (options.oneofs)
                    object.event = "roomAction";
            }
            return object;
        };

        /**
         * Converts this NetworkEvent to JSON.
         * @function toJSON
         * @memberof andere_boxing.NetworkEvent
         * @instance
         * @returns {Object.<string,*>} JSON object
         */
        NetworkEvent.prototype.toJSON = function toJSON() {
            return this.constructor.toObject(this, $protobuf.util.toJSONOptions);
        };

        /**
         * Gets the default type url for NetworkEvent
         * @function getTypeUrl
         * @memberof andere_boxing.NetworkEvent
         * @static
         * @param {string} [typeUrlPrefix] your custom typeUrlPrefix(default "type.googleapis.com")
         * @returns {string} The default type url
         */
        NetworkEvent.getTypeUrl = function getTypeUrl(typeUrlPrefix) {
            if (typeUrlPrefix === undefined) {
                typeUrlPrefix = "type.googleapis.com";
            }
            return typeUrlPrefix + "/andere_boxing.NetworkEvent";
        };

        return NetworkEvent;
    })();

    /**
     * UserAction enum.
     * @name andere_boxing.UserAction
     * @enum {number}
     * @property {number} USER_ACTION_UNSPECIFIED=0 USER_ACTION_UNSPECIFIED value
     * @property {number} USER_ACTION_PUNCH=1 USER_ACTION_PUNCH value
     * @property {number} USER_ACTION_DEFEND=2 USER_ACTION_DEFEND value
     */
    andere_boxing.UserAction = (function() {
        const valuesById = {}, values = Object.create(valuesById);
        values[valuesById[0] = "USER_ACTION_UNSPECIFIED"] = 0;
        values[valuesById[1] = "USER_ACTION_PUNCH"] = 1;
        values[valuesById[2] = "USER_ACTION_DEFEND"] = 2;
        return values;
    })();

    /**
     * RoomAction enum.
     * @name andere_boxing.RoomAction
     * @enum {number}
     * @property {number} ROOM_ACTION_UNSPECIFIED=0 ROOM_ACTION_UNSPECIFIED value
     * @property {number} ROOM_ACTION_CREATE=1 ROOM_ACTION_CREATE value
     * @property {number} ROOM_ACTION_START=2 ROOM_ACTION_START value
     * @property {number} ROOM_ACTION_END=3 ROOM_ACTION_END value
     * @property {number} ROOM_ACTION_DELETE=4 ROOM_ACTION_DELETE value
     * @property {number} ROOM_ACTION_JOIN=5 ROOM_ACTION_JOIN value
     * @property {number} ROOM_ACTION_LEAVE=6 ROOM_ACTION_LEAVE value
     */
    andere_boxing.RoomAction = (function() {
        const valuesById = {}, values = Object.create(valuesById);
        values[valuesById[0] = "ROOM_ACTION_UNSPECIFIED"] = 0;
        values[valuesById[1] = "ROOM_ACTION_CREATE"] = 1;
        values[valuesById[2] = "ROOM_ACTION_START"] = 2;
        values[valuesById[3] = "ROOM_ACTION_END"] = 3;
        values[valuesById[4] = "ROOM_ACTION_DELETE"] = 4;
        values[valuesById[5] = "ROOM_ACTION_JOIN"] = 5;
        values[valuesById[6] = "ROOM_ACTION_LEAVE"] = 6;
        return values;
    })();

    return andere_boxing;
})();

export { $root as default };
