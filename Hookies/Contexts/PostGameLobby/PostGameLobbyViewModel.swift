//
//  PostGameLobbyViewModel.swift
//  Hookies
//
//  Created by Tan LongBin on 21/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol PostGameLobbyViewModelDelegate: class {
    func updateView()
    func leaveLobby()
    func hostHasContinued()
    func lobbyIsFull()
    func continueGame(with lobby: Lobby)
}

protocol PostGameLobbyViewModelRepresentable {
    var lobby: Lobby? { get set }
    var lobbyId: String { get }
    var players: [Player] { get }
    var isHost: Bool { get }
    var delegate: PostGameLobbyViewModelDelegate? { get set }
    func subscribeToLobby()
    func disconnect()
    func continueGame()
    func returnHome()
}

class PostGameLobbyViewModel: PostGameLobbyViewModelRepresentable {
    var lobby: Lobby?
    var lobbyId: String
    var players: [Player] = []
    var isHost: Bool {
        players.contains(where: ({ $0.isCurrentPlayer && $0.isHost }))
    }
    weak var delegate: PostGameLobbyViewModelDelegate?

    init(lobbyId: String, players: [Player]) {
        self.lobbyId = lobbyId
        self.players = players
    }

    func subscribeToLobby() {
        API.shared.lobby.subscribeToLobby(lobbyId: lobbyId, listener: { lobby, error  in
            guard error == nil else {
                Logger.log.show(details: error.debugDescription, logType: .error)
                return
            }
            guard let updatedLobby = lobby else {
                return
            }
            self.lobby = updatedLobby
            self.checkLobbyState()
            self.delegate?.updateView()
        })
    }

    private func checkLobbyState() {
        if !isHost {
            switch lobby?.lobbyState {
            case .open:
                self.delegate?.hostHasContinued()
            case .full:
                self.delegate?.lobbyIsFull()
            case .empty:
                guard let lobby = self.lobby else {
                    return
                }
                if API.shared.user.currentUser?.uid == lobby.hostId {
                    API.shared.lobby.delete(lobbyId: lobby.lobbyId)
                }
                self.delegate?.leaveLobby()
            default:
                return
            }
        }
    }

    func disconnect() {
        API.shared.lobby.unsubscribeFromLobby()
    }

    func returnHome() {
        if self.players.contains(where: { $0.isHost && $0.isCurrentPlayer }) {
            guard var lobby = self.lobby else {
                return
            }
            lobby.updateLobbyState(lobbyState: .empty)
            API.shared.lobby.save(lobby: lobby)
        } else {
            delegate?.leaveLobby()
        }
    }

    func continueGame() {
        guard var lobby = lobby else {
            return
        }
        if isHost {
            lobby.reset()
        } else {
            guard lobby.lobbyState == .open else {
                Logger.log.show(details: "Lobby is not open", logType: .error).display(.toast)
                return
            }
            guard let currentPlayerId = API.shared.user.currentUser?.uid else {
                Logger.log.show(details: "User is not logged in", logType: .error).display(.toast)
                return
            }
            lobby.addPlayer(playerId: currentPlayerId)
        }
        disconnect()
        API.shared.lobby.save(lobby: lobby)
        delegate?.continueGame(with: lobby)
    }
}
