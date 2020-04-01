//
//  FinishLineEventData.swift
//  Hookies
//
//  Created by Jun Wei Koh on 1/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SocketIO

struct FinishLineEventData: SocketData, Encoder {
    let playerData: PlayerData

    var encoding: [String: Any] {
        return playerData.encoding
    }

    init(playerId: String, position: CGPoint, velocity: CGVector?) {
        self.playerData = PlayerData(playerId: playerId, position: position, velocity: velocity)
    }

    init?(data: DictionaryModel) {
        guard let playerData = PlayerData(data: data) else {
            return nil
        }
        self.playerData = playerData
    }

    func socketRepresentation() -> SocketData {
        return encoding
    }
}
