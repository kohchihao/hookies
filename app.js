var app = require('express')();
var http = require('http').createServer(app);
var io = require('socket.io')(http);

gameUsers = {}
socketsMetaData = {}

const games = io.of('/games');
games.on('connection', socket => {
	var gameId = ""

	socket.on('joinGame', (data, ack) => {
		gameId = data.gameId
		const userId = data.user
		addUserToGame(socket.id, gameId, userId)
		socket.join(gameId)
		ack(Array.from(gameUsers[gameId]))
		socket.to(gameId).emit("joinedGame", data.user)
	});

	socket.on('disconnect', () => {
		console.log('user disconnected', socket.id)
		removeClientFromGame(socket.id)
		socket.to(gameId).emit("leftGame", getUser(socket.id))
	});
});

function getUser(socketId) {
	if (hasInvalidSocketStructure(socketId)) {
		return undefined
	}
	var socketData = socketsMetaData[socketId]
	return socketData.userId
}

function removeClientFromGame(socketId) {
	if (hasInvalidSocketStructure(socketId)) {
		return
	}

	var socketData = socketsMetaData[socketId]
	gameUsers[socketData.gameId].delete(socketData.userId)
	if (gameUsers[socketData.gameId].size == 0) {
		delete gameUsers[socketData.gameId]
		delete socketsMetaData[socketId]
	}
}

function hasInvalidSocketStructure(socketId) {
	var socketData = socketsMetaData[socketId]
	return (socketData == undefined || socketData.gameId == undefined || 
		socketData.userId == undefined || gameUsers[socketData.gameId] == undefined)
}

function addUserToGame(socketId, gameId, userId) {
	if (gameUsers[gameId] === undefined) {
		gameUsers[gameId] = new Set([userId])
	} else {
		gameUsers[gameId].add(userId)
	}
	storeGameMetadata(socketId, gameId, userId)
}

function storeGameMetadata(socketId, gameId, userId) {
	socketsMetaData[socketId] = {
		gameId: gameId,
		userId: userId
	}
}

const port = process.env.PORT || 3000
http.listen(port, function() {
	console.log(`listening on *:${port}`);
});
