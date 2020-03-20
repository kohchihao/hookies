//
//  PreGameLobbyViewModel.swift
//  
//
//  Created by Marcus Koh on 15/3/20.
//

import Foundation
import FirebaseAuth
import UIKit

protocol PreGameLobbyViewModelRepresentable {
    var selectedMap: MapType? { get set }
    var delegate: RoomStateViewModelDelegate? { get set }
    var lobby: Lobby { get set }
}

class PreGameLobbyViewModel: PreGameLobbyViewModelRepresentable {
    var selectedMap: MapType?
    weak var delegate: RoomStateViewModelDelegate?
    var lobby: Lobby {
        didSet {
            print("update view model")
            delegate?.updateLobbyViewModel(lobbyViewModel: self)
        }
    }

    init() {
        guard let hostId = Auth.auth().currentUser?.uid else {
            fatalError("Host is not logged in")
        }
        self.lobby = Lobby(hostId: hostId)
        createLobby(lobby: lobby)
        subscribeToLobby(lobby: lobby)
    }

    init(lobby: Lobby) {
        self.lobby = lobby
    }

    func createLobby(lobby: Lobby) {
        API.shared.lobby.save(lobby: lobby)
    }

    func subscribeToLobby(lobby: Lobby) {
        API.shared.lobby.subscribeToLobby(lobbyId: lobby.lobbyId, listener: { lobby, error  in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            guard let updatedLobby = lobby else {
                return
            }
            self.lobby = updatedLobby
        })
    }

    deinit {
        API.shared.lobby.unsubscribeFromLobby()
    }
}

protocol RoomStateViewModelDelegate: class {
    func updateSelectedMap(mapType: MapType)
    func updateLobbyViewModel(lobbyViewModel: PreGameLobbyViewModelRepresentable)
}
