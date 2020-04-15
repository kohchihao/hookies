const Room = require('./Room');

module.exports = class Lobby extends Room {
    constructor(lobbyId) {
        super(lobbyId);
        console.log(`Init new Lobby (${lobbyId})`);
    }
};
