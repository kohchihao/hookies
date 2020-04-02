const GameManager = require('./GameManager');
const app = require('express')();
const http = require('http').createServer(app);
const io = require('socket.io')(http);

const gameManager = new GameManager();
const games = io.of('/games');

games.on('connection', socket => {
	let currentGameId;
	let currentUserId;

	socket.on('joinGame', (data, ack) => {
		currentGameId = data.gameId;
		currentUserId = data.user;
		const currentGame = gameManager.addGameSessionIfDoesNotExist(currentGameId);
		currentGame.addUser(currentUserId);
		socket.join(currentGameId);
		ack(Array.from(currentGame.userIds));
		socket.to(currentGameId).emit("joinedGame", data.user)
	});

	socket.on('powerupActivated', (data) => {
		console.log("here", data);
		socket.to(currentGameId).emit("powerupActivated", data);
	});

	socket.on('hookActionChanged', (data) => {
		console.log("hookActionChange", data);
		socket.to(currentGameId).emit("hookActionChanged", data);
	});

	socket.on('genericPlayerEventDetected', (data) => {
		console.log(data);
		socket.to(currentGameId).emit('genericPlayerEventDetected', data)
	})

	socket.on('disconnect', () => {
		gameManager.removeUserFromGame(currentUserId, currentGameId);
		socket.to(currentGameId).emit("leftGame", currentUserId)
	});
});

const port = process.env.PORT || 3000;
http.listen(port, function() {
	console.log(`listening on *:${port}`);
});
