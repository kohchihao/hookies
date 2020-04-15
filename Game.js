const Room = require('./Room');

module.exports = class Game extends Room {
    constructor(gameId) {
        super(gameId);
        console.log(`Init new Game (${gameId})`);
        this.rankings = [];
        this.hasEnded = false;
    }

    /**
     * Register that the given user has finished the game.
     * @param user - The User instance.
     */
    registerGameEndedFor(user) {
        if (!this.hasUser(user) || this.rankings.includes(user) || this.hasEnded) {
            return
        }

        this.rankings.push(user);
        this.hasEnded = this.rankings.length === this.users.size;
    }
};
