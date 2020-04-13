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

class GameplayStore: SocketRoom {
    private let collection: CollectionReference

    let socket: SocketIOClient

    init(gameplayCollection: CollectionReference,
         socketRef: SocketIOClient
    ) {
        self.collection = gameplayCollection
        self.socket = socketRef
    }

    func broadcastPowerupEvent(powerupEvent: PowerupEventData) {
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
            guard !data.isEmpty, let powerupData = data[0] as? [String: Any] else {
                return
            }
            let model = DictionaryModel(data: powerupData)
            if let result = PowerupCollectionData(data: model) {
                listener(result)
            }
        }
    }

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
