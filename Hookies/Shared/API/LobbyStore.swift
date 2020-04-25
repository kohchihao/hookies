//
//  LobbyStore.swift
//  Hookies
//
//  Created by Jun Wei Koh on 20/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Firebase
import SocketIO

/// A class that is used to interact with the backend database related to game lobby.
class LobbyStore: SocketRoom {
    private let collection: CollectionReference
    let socket: SocketIOClient

    private var lobbyListener: ListenerRegistration?

    init(lobbyCollection: CollectionReference, socketRef: SocketIOClient) {
        collection = lobbyCollection
        socket = socketRef
    }

    /// Will get the Lobby of the given lobby id.
    /// - Parameters:
    ///   - lobbyId: The id of the lobby
    ///   - completion: The callback handler which gets triggered when the async function completes.
    ///                 Will return with the Lobby model.
    func get(lobbyId: String, completion: @escaping (Lobby?, Error?) -> Void) {
        let ref = collection.document(lobbyId)
        ref.getDocumentModel(Lobby.self, completion: { lobby, error in
            if let error = error {
                return completion(nil, error)
            }
            guard let lobby = lobby else {
                return completion(nil, nil)
            }
            completion(lobby, nil)
        })
    }

    func delete(lobbyId: String) {
        let ref = collection.document(lobbyId)
        ref.delete(completion: { error in
            if let error = error {
                print("Error removing the document: \(error)")
            }
        })
    }

    /// Will subscribe to the changes to the lobby data at the backend.
    /// - Parameters:
    ///   - lobbyId: id of the lobby.
    ///   - listener: The callback handler which gets triggered when the async function completes.
    ///               Will return with the Lobby model.
    func subscribeToLobby(lobbyId: String, listener: @escaping (Lobby?, Error?) -> Void) {
        let ref = collection.document(lobbyId)
        lobbyListener = ref.addListener(Lobby.self, listener: { lobby, error in
            listener(lobby, error)
        })
    }

    /// Will remove all the subscriptions in this class instance.
    func unsubscribeFromLobby() {
        lobbyListener?.remove()
    }

    /// Will save the given lobby to the backend database.
    /// - Parameter lobby: The lobby model to save.
    func save(lobby: Lobby) {
        let ref = collection.document(lobby.documentID)
        ref.setDataModel(lobby)
    }
}
