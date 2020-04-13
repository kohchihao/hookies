const GameManager = require('./GameManager');
const LobbyManager = require('./LobbyManager');
const app = require('express')();
const http = require('http').createServer(app);
const io = require('socket.io')(http);

const gameManager = new GameManager();
const lobbyManager = new LobbyManager();
const games = io.of('/games');
const lobbies = io.of('/lobbies');

lobbies.on('connection', socket => {
	let currentLobbyId;
	let currentUserId;
	console.log('connected to lobby');

	socket.on('joinRoom', (data, ack) => {
		currentLobbyId = data.roomId;
		currentUserId = data.user;
		const currentLobby = lobbyManager.addRoomIfDoesNotExist(currentLobbyId);

		if (currentLobby.hasUser(currentUserId)) {
			ack(Array.from(currentLobby.userIds));
			return;
		}

		currentLobby.addUser(currentUserId);
		socket.join(currentLobbyId);
		ack(Array.from(currentLobby.userIds));
		socket.to(currentLobbyId).emit("joinedRoom", data.user)
	});

	socket.on('disconnect', () => {
		console.log('currentUserId', currentUserId, 'disconnected');
		lobbyManager.removeUserFromRoom(currentUserId, currentLobbyId);
		socket.to(currentLobbyId).emit("leftRoom", currentUserId)
	});
});


games.on('connection', socket => {
	let currentGameId;
	let currentUserId;
	console.log('connected to game');

	socket.on('joinRoom', (data, ack) => {
		currentGameId = data.roomId;
		currentUserId = data.user;
		const currentGame = gameManager.addRoomIfDoesNotExist(currentGameId);

		if (currentGame.hasUser(currentUserId)) {
			ack(Array.from(currentGame.userIds));
			return;
		}

		currentGame.addUser(currentUserId);
		socket.join(currentGameId);
		ack(Array.from(currentGame.userIds));
		console.log("emitting join room event");
		socket.to(currentGameId).emit("joinedRoom", data.user)
	});

	socket.on('powerupCollected', (data) => {
		console.log("powerup collected", data);
		socket.to(currentGameId).emit("powerupCollected", data);
	});

	socket.on('powerupEvent', (data) => {
		console.log("powerup event detected", data);
		socket.to(currentGameId).emit("powerupEvent", data);
	});

	socket.on('hookActionChanged', (data) => {
		console.log("hookActionChange", data);
		socket.to(currentGameId).emit("hookActionChanged", data);
	});

	socket.on('genericPlayerEventDetected', (data) => {
		console.log(data);
		socket.to(currentGameId).emit('genericPlayerEventDetected', data)
	});

	socket.on('disconnect', () => {
		console.log('currentUserId', currentUserId, 'disconnected');
		gameManager.removeUserFromRoom(currentUserId, currentGameId);
		socket.to(currentGameId).emit("leftRoom", currentUserId)
	});
});

const port = process.env.PORT || 3000;
http.listen(port, function() {
	console.log(`listening on *:${port}`);
});
