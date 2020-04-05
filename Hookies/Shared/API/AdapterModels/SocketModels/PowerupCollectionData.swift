//
//  PowerupCollectionData.swift
//  Hookies
//
//  Created by Jun Wei Koh on 5/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics
import SocketIO
import SpriteKit

struct PowerupCollectionData: SocketData, Encoder {
    let playerData: PlayerData
    let powerupPos: Vector
    let type: PowerupType

    var encoding: [String: Any] {
        var defaultEncoding: [String: Any] = [
            "type": type.stringValue,
            "powerupPosX": powerupPos.x,
            "powerupPosY": powerupPos.y
        ]
        defaultEncoding.merge(playerData.encoding) { _, new in new }
        print(defaultEncoding)
        return defaultEncoding
    }

    init(playerId: String,
         node: SKSpriteNode,
         powerupPosition: Vector,
         powerupType: PowerupType
    ) {
        self.playerData = PlayerData(playerId: playerId, node: node)
        self.type = powerupType
        self.powerupPos = powerupPosition
    }

    init?(data: DictionaryModel) {
        guard let playerData = PlayerData(data: data) else {
            return nil
        }

        do {
            let powerupTypeString: String = try data.value(forKey: "type")
            guard let type = PowerupType(rawValue: powerupTypeString) else {
                return nil
            }

            let posX: Double = try data.value(forKey: "powerupPosX")
            let posY: Double = try data.value(forKey: "powerupPosY")
            self.type = type
            self.playerData = playerData
            self.powerupPos = Vector(x: posX, y: posY)
        } catch {
            return nil
        }
    }

    func socketRepresentation() -> SocketData {
        return encoding
    }
}

