const app = require('express')();
const http = require('http').createServer(app);
const io = require('socket.io')(http);

const GameManager = require('./GameManager');
const LobbyManager = require('./LobbyManager');
const User = require('./User');

const gameManager = new GameManager();
const lobbyManager = new LobbyManager();
const games = io.of('/games');
const lobbies = io.of('/lobbies');
io.set('heartbeat interval', 3);
io.set('heartbeat timeout', 3);

lobbies.on('connection', socket => {
	let currentLobby;
	let currentUser;
	console.log('connected to lobby');

	socket.on('joinRoom', (data, ack) => {
		currentLobby = lobbyManager.addRoomIfDoesNotExist(data.roomId);
		currentUser = new User(data.user);

		if (currentLobby.hasUser(currentUser)) {
			ack(Array.from(currentLobby.getIdOfUsers()));
			return;
		}

		currentLobby.addUser(currentUser);
		socket.join(currentLobby.id);
		ack(Array.from(currentLobby.getIdOfUsers()));
		socket.to(currentLobby.id).emit("joinedRoom", data.user)
	});

	socket.on('disconnect', () => {
		console.log('currentUserId', currentUser.id, 'disconnected');
		lobbyManager.removeUserFromRoom(currentUser, currentLobby);
		socket.to(currentLobby.id).emit("leftRoom", currentUser.id);
	});
});


games.on('connection', socket => {
	let currentGame;
	let currentUser;
	console.log('connected to game');

	socket.on('joinRoom', (data, ack) => {
		currentGame = gameManager.addRoomIfDoesNotExist(data.roomId);
		currentUser = new User(data.user);

		if (currentGame.hasUser(currentUser)) {
			ack(Array.from(currentGame.getIdOfUsers()));
			return;
		}

		currentGame.addUser(currentUser);
		socket.join(currentGame.id);
		ack(Array.from(currentGame.getIdOfUsers()));
		socket.to(currentGame.id).emit("joinedRoom", currentUser.id)
	});

	socket.on('powerupCollected', (data) => {
		console.log("powerup collected", data);
		socket.to(currentGame.id).emit("powerupCollected", data);
	});

	socket.on('powerupEvent', (data) => {
		console.log("powerup event detected", data);
		socket.to(currentGame.id).emit("powerupEvent", data);
	});

	socket.on('hookActionChanged', (data) => {
		console.log("hookActionChange", data);
		socket.to(currentGame.id).emit("hookActionChanged", data);
	});

	socket.on('genericPlayerEventDetected', (data) => {
		console.log(data);
		socket.to(currentGame.id).emit('genericPlayerEventDetected', data)
	});

	socket.on('registerFinishGame', () => {
		console.log("register finish game for ", currentUser.id);
		gameManager.registerGameEndedFor(currentGame, currentUser);
		if (currentGame.hasEnded) {
			console.log("game ended");
			games.to(currentGame.id).emit('gameEnded', currentGame.rankings.map(u => u.id));
		}
	});

	socket.on('disconnect', () => {
		console.log('currentUserId', currentUser.id, 'disconnected');
		gameManager.removeUserFromRoom(currentUser, currentGame);
		socket.to(currentGame.id).emit("leftRoom", currentUser.id);
		if (currentGame.hasEnded) {
			console.log("game ended");
			socket.in(currentGame.id).emit('gameEnded', currentGame.rankings.map(u => u.id));
		}
	});
});

const port = process.env.PORT || 3000;
http.listen(port, function() {
	console.log(`listening on *:${port}`);
});
