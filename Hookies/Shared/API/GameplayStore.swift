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

/// A class that is used to interact with the backend of the gameplay.
class GameplayStore: SocketRoom {

    let socket: SocketIOClient

    init(socketRef: SocketIOClient) {
        self.socket = socketRef
    }

    /// Will broadcast the specified powerupEvent to other users in the same gameplay
    /// - Parameters:
    ///     - powerupEvent: The powerup event data to broadcast.
    func broadcastPowerupEvent(powerupEvent: PowerupEventData) {
        socket.emit("powerupEvent", powerupEvent)
    }

    /// Will broadcast the collection of powerup to other users in the same gameplay
    /// - Parameters:
    ///     - powerupCollection: The powerup collection event to broadcast.
    func broadcastPowerupCollection(powerupCollection: PowerupCollectionData) {
        Logger.log.show(details: "Broadcasted collection event", logType: .information)
        socket.emit("powerupCollected", powerupCollection)
    }

    /// Will broadcast the specified generic player event to other users in the same gameplay.
    /// - Parameters:
    ///     - playerEvent: The player event data to broadcast.
    func boardcastGenericPlayerEvent(playerEvent: GenericPlayerEventData) {
        socket.emit("genericPlayerEventDetected", playerEvent)
    }

    /// Will broadcast the event of the current player reaching the finish line of the game.
    func registerFinishLineReached() {
        socket.emit("registerFinishGame")
    }

    /// Will broadcast the event of the specified bot reaching the finishing line.
    /// - Parameters:
    ///     - botId: The Id of the bot that reaches the finishing line.
    func registerBotFinishLineReached(for botId: String) {
        socket.emit("registerBotFinishGame", ["user": botId])
    }

    /// Subscribe to the powerup collection of other players.
    /// - Parameters:
    ///     - listener: The call back handler which gets triggered when powerup collection for other
    ///                 players is broadcasted
    func subscribeToPowerupCollection(listener: @escaping (PowerupCollectionData) -> Void) {
        socket.on("powerupCollected") { data, _ in
            guard !data.isEmpty, let powerupData = data[0] as? [String: Any] else {
                return
            }
            let model = DictionaryModel(data: powerupData)
            if let result = PowerupCollectionData(data: model) {
                listener(result)
            }
        }
    }

    /// Subscribe to the powerup event of other players.
    /// - Parameters:
    ///     - listener: The callback handler which gets triggered when a powerup event  for other players is broadcasted
    func subscribeToPowerupEvent(listener: @escaping (PowerupEventData) -> Void) {
        socket.on("powerupEvent") { data, _ in
            guard !data.isEmpty, let powerupData = data[0] as? [String: Any] else {
                return
            }
            let model = DictionaryModel(data: powerupData)
            if let result = PowerupEventData(data: model) {
                listener(result)
            }
        }
    }

    /// Subscribe to the generic player event of other players.
    /// - Parameters:
    ///     - listener: The callback handler which gets triggered when a generic player event  for
    ///                 other players is broadcasted.
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

    /// Subscribe to the game ending event which gets triggered when the game has supposedly ended.
    /// - Parameters:
    ///     - listener: The callback handler which gets triggered when the game has ended.
    ///                 This callback will return the ranking of players.
    func subscribeToGameEndEvent(listener: @escaping ([String]) -> Void) {
        socket.on("gameEnded") { data, _ in
            guard !data.isEmpty, let ranking = data[0] as? [String] else {
                return
            }
            listener(ranking)
        }
    }

    /// Will save the gameState into a persistent database.
    /// - Parameter gameplay: The gameplay model.
    func saveGameState(gameplay: Gameplay) {
        let ref = collection.document(gameplay.documentID)
        ref.setDataModel(gameplay)
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
