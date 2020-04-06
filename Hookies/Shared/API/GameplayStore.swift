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
    /// In the completion handler, it will return you an array of String representing uids of other players
    /// that are currently in the game.
    func connectToGame(gameId: String, completion: @escaping ([String]) -> Void) {
        self.gameId = gameId
        socket.connect()
        socket.once(clientEvent: .connect) { _, _ in
            self.joinGame(gameId: gameId, completion: completion)
        }
    }

    func joinGame(gameId: String, completion: @escaping ([String]) -> Void) {
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

            guard let gameId = self.gameId else {
                return
            }

            self.joinGame(gameId: gameId, completion: { _ in })
        }
        socket.on(clientEvent: .disconnect) { _, _ in
            listener(.disconnected)
        }
        socket.on(clientEvent: .reconnectAttempt, callback: { _, _ in
            listener(.disconnected)
        })
    }

    func broadcastPowerupEvent(powerupEvent: PowerupEventData) {
        print("emit powerupData")
        socket.emit("powerupEvent", powerupEvent)
    }

    func broadcastPowerupCollection(powerupCollection: PowerupCollectionData) {
        socket.emit("powerupCollected", powerupCollection)
    }

    func broadcastHookAction(hookAction: HookActionData) {
        socket.emit("hookActionChanged", hookAction)
    }

    func boardcastGenericPlayerEvent(playerEvent: GenericPlayerEventData) {
        socket.emit("genericPlayerEventDetected", playerEvent)
    }

    func subscribeToPowerupCollection(listener: @escaping (PowerupCollectionData) -> Void) {
        socket.on("powerupCollected") { data, _ in
            print(data)
            guard !data.isEmpty, let powerupData = data[0] as? [String: Any] else {
                return
            }
            let model = DictionaryModel(data: powerupData)
            print("dict model", model)
            if let result = PowerupCollectionData(data: model) {
                print("successfuly converted data")
                listener(result)
            }
        }
    }

    func subscribeToPowerupEvent(listener: @escaping (PowerupEventData) -> Void) {
        socket.on("powerupEvent") { data, _ in
            print(data)
            guard !data.isEmpty, let powerupData = data[0] as? [String: Any] else {
                return
            }
            let model = DictionaryModel(data: powerupData)
            print(model)
            if let result = PowerupEventData(data: model) {
                print("powerupEvent data", result)
                listener(result)
            }
        }
    }

    func subscribeToHookAction(listener: @escaping (HookActionData) -> Void) {
        socket.on("hookActionChanged") { data, _ in
            guard !data.isEmpty, let hookData = data[0] as? [String: Any] else {
                return
            }
            let model = DictionaryModel(data: hookData)
            if let result = HookActionData(data: model) {
                listener(result)
            }
        }
    }

    func subscribeToGenericPlayerEvent(listener: @escaping (GenericPlayerEventData) -> Void) {
        socket.on("genericPlayerEventDetected") { data, _ in
            guard !data.isEmpty, let hookData = data[0] as? [String: Any] else {
                return
            }
            let model = DictionaryModel(data: hookData)
            if let result = GenericPlayerEventData(data: model) {
                listener(result)
            }
        }
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
