const Room = require('./Room');

module.exports = class RoomManager {

    constructor() {
        // Key: Socket ID String
        // Value: Room instance.
        this.rooms = {}
    }


    /**
     * If the associated roomId has no room instance, creates a new room and return that room instance.
     * If not returns an existing room instance already in memory.
     * @param roomId - The String representing the id associated to the room.
     */
    addRoomIfDoesNotExist(roomId) {
        if (this.rooms[roomId] === undefined) {
            const newRoom = new Room(roomId);
            this.addRoom(newRoom);
            return newRoom;
        } else {
            return this.getRoom(roomId);
        }
    }

    /**
     * Get the room instance with the associated roomId. If does not exist, returns undefined.
     * @param roomId - The String representing the id associated to the room.
     */
    getRoom(roomId) {
        return this.rooms[roomId];
    }

    /**
     *
     * @param room - The Room instance to add
     */
    addRoom(room) {
        this.rooms[room.id] = room;
    }

    /**
     * Will remove the user from the room he is in.
     * @param userId - The String representing the id of the user.
     * @param roomId - the String representing the id of the room.
     */
    removeUserFromRoom(userId, roomId) {
        const room = this.rooms[roomId];
        if (room === undefined) {
            return;
        }
        room.removeUser(userId);
        if (room.size() === 0) {
            this.deleteRoom(roomId);
        }
    }

    /**
     * Will delete the room instance. If no such room exist, do nothing.
     * @param roomId - The String representing the id of the room instance.
     */
    deleteRoom(roomId) {
        if (this.rooms[roomId] === undefined) {
            return;
        }
        delete this.rooms[roomId];
    }
};
