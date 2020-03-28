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
    let playerId: String
    let powerup: Powerup
    let position: CGPoint
    var velocity: CGVector?

    var encoding: [String: Any] {
        return defaultEncoding()
    }

    init(player: Player, powerup: Powerup) {
        self.playerId = player.id
        self.powerup = powerup
        self.position = player.node.position
        self.velocity = player.node.physicsBody?.velocity
    }

    init?(data: DictionaryModel) {
        do {
            self.playerId = try data.value(forKey: "playerId")
            guard let powerName: String = data.optionalValue(forKey: "powerupName"),
                let isPowerupActivated: Bool = data.optionalValue(forKey: "isPowerupActivated"),
                let powerup = PowerupCreator.create(name: powerName, isActivated: isPowerupActivated,
                                                    ownerId: data.optionalValue(forKey: "powerupOwnerId")) else {
                return nil
            }
            self.powerup = powerup
            self.position = CGPoint(x: try data.value(forKey: "positionX") as Double,
                                    y: try data.value(forKey: "positionY") as Double)
            if let velocityX: Double = data.optionalValue(forKey: "velocityX"),
                let velocityY: Double = data.optionalValue(forKey: "velocityY") {
                    self.velocity = CGVector(dx: velocityX, dy: velocityY)
            }
        } catch {
            return nil
        }
    }

    func socketRepresentation() -> SocketData {
        return encoding
    }
}
