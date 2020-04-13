module.exports = class Room {

    /**
     *
     * @param roomId - The id of this room.
     */
    constructor(roomId) {
        this.userIds = new Set();
        this.id = roomId;
    }

    /**
     *
     * @param userId - String representing the user Id
     */
    addUser(userId) {
        this.userIds.add(userId);
    }

    /**
     *
     * @param userId - String representing the user Id
     */
    removeUser(userId) {
        this.userIds.delete(userId);
    }

    size() {
        return this.userIds.size;
    }
};
