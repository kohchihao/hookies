//
//  PowerupData.swift
//  Hookies
//
//  Created by Jun Wei Koh on 26/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics
import SocketIO

struct PowerupActionData: SocketData, Encoder {
    let powerup: Powerup
    let playerData: PlayerData

    var encoding: [String: Any] {
        var defaultEncoding = powerup.representation
        defaultEncoding.merge(playerData.encoding) { _, new in new }
        return defaultEncoding
    }

    init(playerId: String, position: CGPoint, velocity: CGVector?, powerup: Powerup) {
        self.powerup = powerup
        self.playerData = PlayerData(playerId: playerId, position: position, velocity: velocity)
    }

    init?(data: DictionaryModel) {
        guard let powerName: String = data.optionalValue(forKey: "powerupName"),
            let isPowerupActivated: Bool = data.optionalValue(forKey: "isPowerupActivated") else {
            return nil
        }
        guard let powerup = PowerupCreator.create(name: powerName, isActivated: isPowerupActivated,
                                                  ownerId: data.optionalValue(forKey: "powerupOwnerId")),
            let playerData = PlayerData(data: data) else {
                return nil
        }
        self.powerup = powerup
        self.playerData = playerData
    }

    func socketRepresentation() -> SocketData {
        return encoding
    }
}
