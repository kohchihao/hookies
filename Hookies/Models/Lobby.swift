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
    private(set) var playersId: [String]

    init(hostId: String) {
        lobbyId = UUID().uuidString
        self.hostId = hostId
        self.playersId = [hostId]
    }

    init(hostId: String, playersId: [String]) {
        lobbyId = UUID().uuidString
        self.hostId = hostId
        self.playersId = playersId
    }

    mutating func addPlayerId(playerId: String) {
        guard !playersId.contains(playerId) && playerId != hostId else {
            return
        }
        playersId.append(playerId)
    }
}
