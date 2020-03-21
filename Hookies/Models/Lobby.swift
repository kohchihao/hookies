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
    private(set) var selectedMapType: MapType?
    private(set) var costumesId: [String: CostumeType]

    init(hostId: String) {
        lobbyId = RandomIDGenerator.getRandomID(length: 6)
        self.hostId = hostId
        self.playersId = [hostId]
        self.costumesId = [hostId: .Pink_Monster]
    }

    init(hostId: String, playersId: [String], costumesId: [String: CostumeType]) {
        self.init(hostId: hostId)
        for playerId in playersId {
            addPlayer(playerId: playerId)
        }
        for (playerId, costumeType) in costumesId {
            updateCostumeId(playerId: playerId, costumeType: costumeType)
        }
    }

    init(lobbyId: String, hostId: String, selectedMapType: MapType?,
         playersId: [String], costumesId: [String: CostumeType]) {
        self.lobbyId = lobbyId
        self.hostId = hostId
        self.selectedMapType = selectedMapType
        self.playersId = playersId
        self.costumesId = costumesId
    }

    mutating func addPlayer(playerId: String) {
        guard !playersId.contains(playerId) && playerId != hostId else {
            return
        }
        playersId.append(playerId)
        updateCostumeId(playerId: playerId, costumeType: .Pink_Monster)
    }

    mutating func updateCostumeId(playerId: String, costumeType: CostumeType) {
        if playersId.contains(playerId) {
            self.costumesId[playerId] = costumeType
        }
    }

    mutating func updateSelectedMapType(selectedMapType: MapType) {
        self.selectedMapType = selectedMapType
    }
}
