//
//  Lobby.swift
//  Hookies
//
//  Created by Tan LongBin on 19/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

struct Lobby {
    private(set) var lobbyId: String
    private(set) var hostId: String
    private(set) var lobbyState: LobbyState
    private(set) var playersId: [String]
    private(set) var selectedMapType: MapType?
    private(set) var costumesId: [String: CostumeType]

    init(hostId: String) {
        lobbyId = RandomIDGenerator.getRandomID(length: Constants.lobbyIdLength)
        self.hostId = hostId
        self.playersId = [hostId]
        if let costume = CostumeType.getDefault() {
            self.costumesId = [hostId: costume]
        } else {
            self.costumesId = [:]
        }
        self.lobbyState = .open
    }

    init(hostId: String, playersId: [String], costumesId: [String: CostumeType]) {
        self.init(hostId: hostId)
        self.lobbyState = .open
        for playerId in playersId {
            addPlayer(playerId: playerId)
        }
        for (playerId, costumeType) in costumesId {
            updateCostumeId(playerId: playerId, costumeType: costumeType)
        }
    }

    init(lobbyId: String, hostId: String, lobbyState: LobbyState,
         selectedMapType: MapType?, playersId: [String],
         costumesId: [String: CostumeType]) {
        self.lobbyId = lobbyId
        self.hostId = hostId
        self.lobbyState = lobbyState
        self.selectedMapType = selectedMapType
        self.playersId = playersId
        self.costumesId = costumesId
    }

    /// Add player ID to lobby
    /// - Parameter playerId: player ID to be added
    mutating func addPlayer(playerId: String) {
        guard !playersId.contains(playerId) && playerId != hostId && lobbyState == .open else {
            return
        }
        playersId.append(playerId)
        if !self.costumesId.keys.contains(playerId) {
            if let costume = CostumeType.getDefault() {
                updateCostumeId(playerId: playerId, costumeType: costume)
            }
        }
        if playersId.count == Constants.maxPlayerCount {
            lobbyState = .full
        }
    }

    /// Remove player ID from lobby
    /// - Parameter playerId: player ID to be removed
    mutating func removePlayer(playerId: String) {
        guard playerId != hostId else {
            lobbyState = .empty
            return
        }
        playersId = playersId.filter({ $0 != playerId })
        removeCostumeId(playerId: playerId)
        if lobbyState == .full && playersId.count < Constants.maxPlayerCount {
            lobbyState = .open
        }
    }

    /// Update costume of player
    /// - Parameters:
    ///   - playerId: player ID of the player
    ///   - costumeType: costume type of the player
    mutating func updateCostumeId(playerId: String, costumeType: CostumeType) {
        if playersId.contains(playerId) {
            self.costumesId[playerId] = costumeType
        }
    }

    /// Remove costume of player
    /// - Parameter playerId: player id of the player
    mutating private func removeCostumeId(playerId: String) {
        self.costumesId = self.costumesId.filter({ $0.key != playerId })
    }

    /// Update the selected map in the lobby
    mutating func updateSelectedMapType(selectedMapType: MapType) {
        self.selectedMapType = selectedMapType
    }

    /// Update the lobby state of the lobby
    mutating func updateLobbyState(lobbyState: LobbyState) {
        switch lobbyState {
        case .open:
            guard playersId.count < Constants.maxPlayerCount else {
                return
            }
        case .full:
            guard playersId.count == Constants.maxPlayerCount else {
                return
            }
        case .start:
            guard !playersId.isEmpty && playersId.count <= Constants.maxPlayerCount else {
                return
            }
        case .empty:
            self.playersId = [hostId]
        }
        self.lobbyState = lobbyState
    }

    /// Reset the lobby 
    mutating func reset() {
        self.playersId = [hostId]
        self.lobbyState = .open
    }
}
