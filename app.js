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
		ack(Array.from(gameUsers[currentGameId]));
		socket.to(currentGameId).emit("joinedGame", data.user)
	});

	socket.on('disconnect', () => {
		// removeClientFromGame(socket.id);
		gameManager.removeUserFromGame(currentUserId, currentGameId);
		socket.to(currentGameId).emit("leftGame", getUser(socket.id))
	});
});

const port = process.env.PORT || 3000
http.listen(port, function() {
	console.log(`listening on *:${port}`);
});
