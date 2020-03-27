module.exports = class Game {

    /**
     *
     * @param gameId - The gameId of this room.
     */
    constructor(gameId) {
        this.userIds = new Set();
        this.id = gameId;
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
}
