//
//  PreGameLobbyViewModel.swift
//  
//
//  Created by Marcus Koh on 15/3/20.
//

import Foundation

protocol PreGameLobbyViewModelRepresentable {
    var delegate: RoomStateViewModelDelegate? { get set }
    var lobby: Lobby { get set }
    func updateSelectedMapType(selectedMapType: MapType)
}

class PreGameLobbyViewModel: PreGameLobbyViewModelRepresentable {
    weak var delegate: RoomStateViewModelDelegate?
    var lobby: Lobby

    init() {
        guard let hostId = API.shared.user.currentUser?.uid else {
            fatalError("Host is not logged in")
        }
        self.lobby = Lobby(hostId: hostId)
    }

    init(lobby: Lobby) {
        self.lobby = lobby
    }

    func updateSelectedMapType(selectedMapType: MapType) {
        self.lobby.updateSelectedMapType(selectedMapType: selectedMapType)
    }
}

protocol RoomStateViewModelDelegate: class {
    func updateSelectedMap(mapType: MapType)
    func updateLobbyViewModel(lobbyViewModel: PreGameLobbyViewModelRepresentable)
}
