const Game = require('./Game');

module.exports = class GameManager {

    constructor() {
        // A dictionary with key of socketId and value of Game instance.
        this.games = {}
    }


    /**
     * If the associated gameId has no game instance, creates a new game and return that game instance.
     * If not returns an existing game instance already in memory.
     * @param gameId - The String representing the id associated to the game.
     */
    addGameSessionIfDoesNotExist(gameId) {
        if (this.games[gameId] === undefined) {
            const newGame = new Game(gameId);
            return this.addGame(newGame);
        } else {
            return this.getGame(gameId);
        }
    }

    /**
     * Get the game instance with the associated gameId. If does not exist, returns undefined.
     * @param gameId - The String representing the id associated to the game.
     */
    getGame(gameId) {
        return this.games[gameId];
    }

    /**
     *
     * @param game - The Game instance to add
     */
    addGame(game) {
        this.games[game.id] = game;
    }

    /**
     * Will remove the user from the game he is in.
     * @param userId - The String representing the id of the user.
     * @param gameId - the String representing the id of the game.
     */
    removeUserFromGame(userId, gameId) {
        const game = this.games[gameId];
        if (game === undefined) {
            return;
        }
        game.removeUser(userId);
        if (game.size() === 0) {
            this.deleteGame(gameId);
        }
    }

    /**
     * Will delete the game instance. If no such game exist, do nothing.
     * @param gameId - The String representing the id of the game instance.
     */
    deleteGame(gameId) {
        if (this.games[gameId] === undefined) {
            return;
        }
        delete this.games[gameId];
    }
}
