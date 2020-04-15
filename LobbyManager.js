const RoomManager = require('./RoomManager');
const Lobby = require('./Lobby');

module.exports = class LobbyManager extends RoomManager {
    constructor() {
        super(Lobby);
    }
};
