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
    var isHost: Bool { get }
    var isOnline: Bool { get }
    func nextCostume()
    func prevCostume()
    func prepareGame()
    func addBot()
    func leaveLobby()
    func closeLobbyConnection()
}

class PreGameLobbyViewModel: PreGameLobbyViewModelRepresentable {

    weak var delegate: RoomStateViewModelDelegate?
    var lobby: Lobby
    var isOnline = false
    var isHost: Bool

    convenience init() {
        guard let hostId = API.shared.user.currentUser?.uid else {
            fatalError("Host is not logged in")
        }
        let lobby = Lobby(hostId: hostId)
        self.init(lobby: lobby)
    }

    init(lobby: Lobby) {
        self.lobby = lobby
        isHost = lobby.hostId == API.shared.user.currentUser?.uid
        saveLobby(lobby: lobby)
        subscribeToLobby(lobby: lobby)
        connectToSocket()
        NetworkManager.shared.set(gameId: self.lobby.lobbyId)
    }

    deinit {
        closeLobbyConnection()
    }

    func updateSelectedMapType(selectedMapType: MapType) {
        lobby.updateSelectedMapType(selectedMapType: selectedMapType)
        saveLobby(lobby: lobby)
    }

    // MARK: LobbyStore

    func subscribeToLobby(lobby: Lobby) {
        API.shared.lobby.subscribeToLobby(lobbyId: lobby.lobbyId, listener: { lobby, error  in
            guard error == nil else {
                Logger.log.show(details: error.debugDescription, logType: .error)
                return
            }
            guard let updatedLobby = lobby else {
                self.delegate?.leaveLobby()
                return
            }
            self.lobby = updatedLobby
            if updatedLobby.lobbyState == .empty {
                if API.shared.user.currentUser?.uid == self.lobby.hostId {
                    API.shared.lobby.delete(lobbyId: self.lobby.lobbyId)
                }
                self.delegate?.leaveLobby()
            }
            if self.lobby.lobbyState == .start {
                self.startGame()
            }
            self.delegate?.updateView()
        })
    }

    private func connectToSocket() {
        API.shared.lobby.connect(roomId: self.lobby.lobbyId, completion: { _ in })
        API.shared.lobby.subscribeToRoomConnection(roomId: self.lobby.lobbyId, listener: { connectionState in
            switch connectionState {
            case .connected:
                self.isOnline = true
            case .disconnected:
                self.isOnline = false
                if !self.isHost {
                    self.leaveLobby()
                }
            }
            self.delegate?.updateView()
        })
        API.shared.lobby.subscribeToPlayersConnection(listener: { userConnection in
            switch userConnection.state {
            case .connected:
                break
            case .disconnected:
                if self.isHost {
                    self.lobby.removePlayer(playerId: userConnection.uid)
                    API.shared.lobby.save(lobby: self.lobby)
                }
            }
        })
    }

    func saveLobby(lobby: Lobby) {
        API.shared.lobby.save(lobby: lobby)
    }

    func closeLobbyConnection() {
        API.shared.lobby.unsubscribeFromLobby()
        API.shared.lobby.close()
    }

    // MARK: Costumes

    func nextCostume() {
        guard let userId = API.shared.user.currentUser?.uid else {
            return
        }
        let currentCostume = lobby.costumesId[userId]
        guard let nextCostume = CostumeType.nextCostume(currentCostume: currentCostume) else {
            return
        }
        lobby.updateCostumeId(playerId: userId, costumeType: nextCostume)
        saveLobby(lobby: lobby)
    }

    func prevCostume() {
        guard let userId = API.shared.user.currentUser?.uid else {
            return
        }
        let currentCostume = lobby.costumesId[userId]
        guard let prevCostume = CostumeType.prevCostume(currentCostume: currentCostume) else {
            return
        }
        lobby.updateCostumeId(playerId: userId, costumeType: prevCostume)
        saveLobby(lobby: lobby)
    }

    // MARK: Start Game

    func prepareGame() {
        if API.shared.user.currentUser?.uid == lobby.hostId {
            lobby.updateLobbyState(lobbyState: .start)
            saveLobby(lobby: lobby)
        } else {
            Logger.log.show(details: "Host not found", logType: .error).display(.toast)
        }

    }

    func startGame() {
        let players = createPlayers()
        delegate?.startGame(with: players)
    }

    // swiftlint:disable line_length

    private func createPlayers() -> [Player] {
        var players: [Player] = []
        guard let currentId = API.shared.user.currentUser?.uid else {
            Logger.log.show(details: "Current player not found.", logType: .error)
            return players
        }
        for playerId in lobby.playersId {
            guard let costume = lobby.costumesId[playerId] ?? CostumeType.getDefault() else {
                continue
            }
            if playerId.contains(Constants.botPrefix) {
                guard let botType = BotType.getRandom() else {
                    continue
                }
                if let bot = Player(playerId: playerId, playerType: .bot, costumeType: costume, botType: botType) {
                    players.append(bot)
                }
            } else {
                if let player = Player(playerId: playerId, playerType: .human, costumeType: costume, isCurrentPlayer: currentId == playerId, isHost: isHost) {
                    players.append(player)
                }
            }
        }
        return players
    }

    // MARK: Leave Lobby

    func leaveLobby() {
        if isHost {
            lobby.updateLobbyState(lobbyState: .empty)
            API.shared.lobby.save(lobby: lobby)
        } else {
            guard let currentPlayerId = API.shared.user.currentUser?.uid else {
                return
            }
            lobby.removePlayer(playerId: currentPlayerId)
            saveLobby(lobby: lobby)
            delegate?.leaveLobby()
        }
    }

    // MARK: Bot

    func addBot() {
        guard lobby.playersId.count < Constants.maxPlayerCount else {
            Logger.log.show(details: "max number of players exceeded", logType: .error).display(.toast)
            return
        }
        let botId = Constants.botPrefix + RandomIDGenerator.getRandomID(length: Constants.botUsernameLength)
        lobby.addPlayer(playerId: botId)
        guard let costume = CostumeType.getRandom() else {
            return
        }
        lobby.updateCostumeId(playerId: botId, costumeType: costume)
        saveLobby(lobby: lobby)
    }
}

protocol RoomStateViewModelDelegate: class {
    func leaveLobby()
    func startGame(with players: [Player])
    func updateView()
}
