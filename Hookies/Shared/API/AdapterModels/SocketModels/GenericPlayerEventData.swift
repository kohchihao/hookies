//
//  FinishLineEventData.swift
//  Hookies
//
//  Created by Jun Wei Koh on 1/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SocketIO

struct GenericPlayerEventData: SocketData, Encoder {
    let playerData: PlayerData
    let type: GenericPlayerEvent

    var encoding: [String: Any] {
        return playerData.encoding
    }

    init(playerId: String, position: Vector, velocity: Vector?, type: GenericPlayerEvent) {
        self.playerData = PlayerData(playerId: playerId, position: position, velocity: velocity)
        self.type = type
    }

    init?(data: DictionaryModel) {
        do {
            guard let playerData = PlayerData(data: data),
                let type = try GenericPlayerEvent(rawValue: data.value(forKey: "type")) else {
                    return nil
            }
            self.playerData = playerData
            self.type = type
        } catch {
            return nil
        }
    }

    func socketRepresentation() -> SocketData {
        return encoding
    }
}
