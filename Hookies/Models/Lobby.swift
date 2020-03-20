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
    private(set) var mapId: String?
    private(set) var playersId: [String]
    /// A dictionary with key of playerId and value of costumeId
    private(set) var costumes: [String: String]

    init(hostId: String) {
        lobbyId = UUID().uuidString
        self.hostId = hostId
        self.playersId = []
        self.costumes = [:]
    }

    init(hostId: String, mapId: String, playersId: [String]) {
        lobbyId = UUID().uuidString
        self.hostId = hostId
        self.mapId = mapId
        self.playersId = playersId
        self.costumes = [:]
    }

    init(lobbyId: String, hostId: String, mapId: String?, playersId: [String],
         costumes: [String: String]) {
        self.lobbyId = lobbyId
        self.hostId = hostId
        self.mapId = mapId
        self.playersId = playersId
        self.costumes = costumes
    }

    mutating func addPlayerId(playerId: String) {
        guard !playersId.contains(playerId) && playerId != hostId else {
            return
        }
        playersId.append(playerId)
    }
}
