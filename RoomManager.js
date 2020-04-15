
module.exports = class RoomManager {

    constructor(roomType) {
        // Set of Room instance
        this.rooms = new Set();
        this.roomType = roomType;
    }


    /**
     * If the associated roomId has no room instance, creates a new room and return that room instance.
     * If not returns an existing room instance already in memory.
     * @param roomId - The String representing the id associated to the room.
     */
    addRoomIfDoesNotExist(roomId) {
        if (this.hasExistingRoomWithId(roomId)) {
            return this.getRoom(roomId)
        } else {
            const newRoom = new this.roomType(roomId);
            this.addRoom(newRoom);
            return newRoom;
        }
    }

    /**
     * Get the room instance with the associated roomId. If does not exist, returns undefined.
     * @param roomId - The room instance
     */
    getRoom(roomId) {
        return Array.from(this.rooms).find(room => room.id === roomId);
    }

    /**
     *
     * @param room - The Room instance to add
     */
    addRoom(room) {
        if (this.hasExistingRoomWithId(room.id)) {
            return;
        }
        this.rooms.add(room);
    }

    /**
     * Will remove the user from the room he is in.
     * @param user - The User instance.
     * @param room - the Room instance.
     */
    removeUserFromRoom(user, room) {
        if (room === undefined || !this.rooms.has(room)) {
            return;
        }

        room.removeUser(user);
        if (room.size() === 0) {
            this.deleteRoom(room);
        }
    }

    /**
     * Will delete the room instance. If no such room exist, do nothing.
     * @param room - The room instance to be deleted.
     */
    deleteRoom(room) {
        this.rooms.forEach(currentRoom => {
            if (currentRoom.id === room.id) {
                this.rooms.delete(currentRoom);
            }
        });
    }

    /**
     * Will determine whether there exist a room with the provided id.
     */
    hasExistingRoomWithId(roomId) {
        return Array.from(this.rooms).reduce((result, room) => {
            return result || room.id === roomId;
        }, false);
    }
};
