module.exports = class Room {

    /**
     *
     * @param roomId - The id of this room.
     */
    constructor(roomId) {
        this.users = new Set();
        this.id = roomId;
    }

    /**
     *
     * @param user - The user instance
     */
    addUser(user) {
        if (this.hasUser(user)) {
            return;
        }
        this.users.add(user);
    }

    /**
     *
     * @param user - The user instance
     */
    removeUser(user) {
        this.users.forEach(currentUser => {
            if (currentUser.id === user.id) {
                this.users.delete(currentUser);
            }
        });
    }

    /**
     * @param user - The user instance
     */
    hasUser(user) {
        return this.getIdOfUsers().includes(user.id);
    }

    /**
     *
     * @return Array of user id in the room.
     */
    getIdOfUsers() {
        return Array.from(this.users).map(user => user.id);
    }

    size() {
        return this.users.size;
    }
};
