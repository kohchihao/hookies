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

class LobbyStore: SocketRoom {
    private let collection: CollectionReference
    let socket: SocketIOClient

    private var lobbyListener: ListenerRegistration?

    init(lobbyCollection: CollectionReference, socketRef: SocketIOClient) {
        collection = lobbyCollection
        socket = socketRef
    }

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

    func subscribeToLobby(lobbyId: String, listener: @escaping (Lobby?, Error?) -> Void) {
        let ref = collection.document(lobbyId)
        lobbyListener = ref.addListener(Lobby.self, listener: { lobby, error in
            listener(lobby, error)
        })
    }

    func unsubscribeFromLobby() {
        lobbyListener?.remove()
    }

    func save(lobby: Lobby) {
        let ref = collection.document(lobby.documentID)
        ref.setDataModel(lobby)
    }
}
