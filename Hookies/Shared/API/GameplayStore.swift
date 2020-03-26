//
//  GameplayStore.swift
//  Hookies
//
//  Created by Jun Wei Koh on 16/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Firebase
import SocketIO

class GameplayStore {
    private let collection: CollectionReference
    private let socket: SocketIOClient
    private let timeout = 1.0 // In seconds
    private var gameId: String?

    private var playerStateListeners: [ListenerRegistration]
    private var gameStateListener: ListenerRegistration?

    init(gameplayCollection: CollectionReference, socketRef: SocketIOClient) {
        self.collection = gameplayCollection
        self.socket = socketRef
        self.playerStateListeners = []
    }

    /// Will remove all listeners that has been added the current game session.
    func closeGameSession() {
        socket.removeAllHandlers()
    }

    /// Connect the current user to the defined game id.
    func connectToGame(gameId: String) {
        self.gameId = gameId
        socket.connect()
    }

    /// Will broadcast to other players your entrance into the game room, if you are not connect will do nothing.
    /// So remember to call `connectToGame(gameId: String)`.
    /// In return, the completion handler will return to you the uids of other players that are currently in the game.
    func broadcastEntrance(completion: @escaping ([String]) -> Void) {
        socket.once(clientEvent: .connect) { _, _ in
            guard let currentUser = API.shared.user.currentUser,
                let gameId = self.gameId else {
                    return
            }
            self.socket.emitWithAck("joinGame", [
                "user": currentUser.uid,
                "gameId": gameId
            ]).timingOut(after: self.timeout) { ack in
                let otherOnlineUsers = self.decodePlayersInRoomData(data: ack)
                    .filter({ $0 != currentUser.uid })
                completion(otherOnlineUsers)
            }
        }
    }

    /// Whenever there is a change in connection status of other players, the listener will be triggered.
    func subscribeToPlayersConnection(listener: @escaping (UserConnectionState) -> Void) {
        socket.on("joinedGame") { data, _ in
            guard let userId = self.decodeStringData(data: data) else {
                return
            }
            listener(UserConnectionState(uid: userId, state: .connected))
        }
        socket.on("leftGame") { data, _ in
            guard let userId = self.decodeStringData(data: data) else {
                return
            }
            listener(UserConnectionState(uid: userId, state: .disconnected))
        }
    }

    /// Whenever there is a change in connection status of the current user, the listener will be triggered.
    func subscribeToGameConnection(listener: @escaping (ConnectionState) -> Void) {
        socket.on(clientEvent: .connect) { _, _ in
            listener(.connected)
        }
        socket.on(clientEvent: .disconnect) { _, _ in
            listener(.disconnected)
        }
    }

    func subscribeToPlayerState(gameId: String, playerId: String,
                                listener: @escaping (PlayerGameState?, Error?) -> Void) {
        let ref = playerStatesCollection(for: gameId).document(playerId)
        let listener = ref.addListener(PlayerGameState.self, listener: { playerState, error in
            listener(playerState, error)
        })
        playerStateListeners.append(listener)
    }

    func subscribeToGameState(gameId: String, listener: @escaping (Gameplay?, Error?) -> Void) {
        let ref = collection.document(gameId)
        gameStateListener = ref.addListener(Gameplay.self, listener: { gameplay, error in
            listener(gameplay, error)
        })
    }

    func unsubscribeFromPlayerStates() {
        playerStateListeners.forEach({ $0.remove() })
    }

    func unsubscribeFromGameState() {
        gameStateListener?.remove()
    }

    func savePlayerState(gameId: String, playerState: PlayerGameState) {
        let ref = playerStatesCollection(for: gameId).document(playerState.documentID)
        ref.setDataModel(playerState)
    }

    func saveGameState(gameplay: Gameplay) {
        let ref = collection.document(gameplay.documentID)
        ref.setDataModel(gameplay)
    }

    private func playerStatesCollection(for gameId: String) -> CollectionReference {
        return self.collection.document(gameId).collection("playerStates")
    }

    private func decodePlayersInRoomData(data: [Any]) -> [String] {
        return data.compactMap({ $0 as? [String] })
            .flatMap({ $0 })
    }

    private func decodeStringData(data: [Any]) -> String? {
        if data.isEmpty {
            return nil
        }
        return data.compactMap({ $0 as? String })[0]
    }
}
