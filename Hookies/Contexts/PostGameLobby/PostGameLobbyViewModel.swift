//
//  PostGameLobbyViewModel.swift
//  Hookies
//
//  Created by Tan LongBin on 21/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol PostGameLobbyViewModelDelegate: class {
    func lobbyLoaded(isLoaded: Bool)
}

protocol PostGameLobbyViewModelRepresentable {
    var lobby: Lobby? { get set }
    var lobbyId: String { get }
    var players: [Player] { get }
    var delegate: PostGameLobbyViewModelDelegate? { get set }
    func updateLobby()
}

class PostGameLobbyViewModel: PostGameLobbyViewModelRepresentable {
    var lobby: Lobby?
    var lobbyId: String
    var players: [Player] = []
    weak var delegate: PostGameLobbyViewModelDelegate?

    init(lobbyId: String, players: [Player]) {
        self.lobbyId = lobbyId
        self.players = players
    }

    func updateLobby() {
        API.shared.lobby.get(lobbyId: lobbyId, completion: { lobby, error in
            guard error == nil else {
                Logger.log.show(details: error.debugDescription, logType: .error)
                self.delegate?.lobbyLoaded(isLoaded: false)
                return
            }
            guard var lobby = lobby else {
                self.delegate?.lobbyLoaded(isLoaded: false)
                return
            }
            if lobby.lobbyState == .start {
                lobby.updateLobbyState(lobbyState: .empty)
            }
            API.shared.lobby.save(lobby: lobby)
            self.lobby = lobby
            self.delegate?.lobbyLoaded(isLoaded: true)
        })
    }
}
