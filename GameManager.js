const RoomManager = require('./RoomManager');
const Game = require('./Game');

module.exports = class GameManager extends RoomManager {
    constructor() {
        super(Game);
    }

    /**
     * Register that the given user has finished the given game.
     * @param game - The Game instance.
     * @param user - The User instance.
     */
    registerGameEndedFor(game, user) {
        if (!this.hasExistingRoomWithId(game.id)) {
            return
        }
        game.registerGameEndedFor(user);
    }

    /**
     * Checks whether the given game has ended
     */
    hasGameEnded(game) {
        if (!this.hasExistingRoomWithId(game.id)) {
            return true;
        }
        return game.hasGameEnded();
    }
};
