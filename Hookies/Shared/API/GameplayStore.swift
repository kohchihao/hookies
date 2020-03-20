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

    private var playerStatesListener: ListenerRegistration?

    init(gameplayCollection: CollectionReference) {
        collection = gameplayCollection
    }

    /// Get a gameplay with the given uid.
    func get(gameId: String, completion: @escaping (_ gameplay: Gameplay?, _ error: Error?) -> Void) {
        let ref = collection.document(gameId)
        ref.getDocumentModel(Gameplay.self, completion: { gameplay, error  in
            guard var gameplay = gameplay else {
                return
            }
            let playerStateCollection = self.playerStatesCollection(for: gameId)
            playerStateCollection.getModels(PlayerGameState.self, completion: { states, error in
                if let error = error {
                    return completion(nil, error)
                }
                guard let states = states else {
                    return completion(nil, nil)
                }
                gameplay.updatePlayerStates(with: states)
                completion(gameplay, nil)
            })
        })
    }

    /// Adds a listener to constantly receive updates from firestore whenever there are changes in data in
    /// players states in the specified game.
    /// Remeber to unsubscribe when not needed to prevent memory leaks.
    func subscribeToPlayerStates(gameId: String,
                                 listener: @escaping ([PlayerGameState]?, Error?) -> Void) {
        let playerStates = playerStatesCollection(for: gameId)
        playerStatesListener = playerStates.addListener(PlayerGameState.self, listener: { state, error in
            listener(state, error)
        })
    }

    /// Remove the current listener of player states.
    func unsubscribeFromPlayerStates() {
        playerStatesListener?.remove()
    }

    /// Save an instance of gameplay into firestore.
    func save(gameplay: Gameplay) {
        let ref = collection.document(gameplay.documentID)
        ref.setDataModel(gameplay)
        for state in gameplay.playersGameState {
            let stateRef = self.playerStatesCollection(for: gameplay.gameId).document(state.playerId)
            stateRef.setDataModel(state)
        }
    }

    private func playerStatesCollection(for gameId: String) -> CollectionReference {
        return self.collection.document(gameId).collection("playerStates")
    }
}
