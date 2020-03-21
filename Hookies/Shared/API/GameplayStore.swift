//
//  GameplayStore.swift
//  Hookies
//
//  Created by Jun Wei Koh on 16/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Firebase

class GameplayStore {
    private let collection: CollectionReference

    private var playerStateListeners: [ListenerRegistration]
    private var gameStateListener: ListenerRegistration?

    init(gameplayCollection: CollectionReference) {
        collection = gameplayCollection
        playerStateListeners = []
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
}
