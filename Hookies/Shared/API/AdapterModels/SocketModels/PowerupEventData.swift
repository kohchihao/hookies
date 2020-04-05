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
import SpriteKit

struct PowerupEventData: SocketData, Encoder {
    let playerData: PlayerData
    let type: PowerupType
    let eventType: PowerupEventType
    let eventPos: Vector

    var encoding: [String: Any] {
        var defaultEncoding: [String: Any] = [
            "type": type.stringValue,
            "eventType": eventType.stringValue,
            "eventPosX": eventPos.x,
            "eventPosY": eventPos.y
        ]
        defaultEncoding.merge(playerData.encoding) { _, new in new }
        return defaultEncoding
    }

    init(playerId: String,
         node: SKSpriteNode,
         eventType: PowerupEventType,
         powerupType: PowerupType,
         eventPos: Vector? = nil
    ) {
        if eventPos == nil {
            self.eventPos = Vector(point: node.position)
        } else {
            self.eventPos = eventPos!
        }
        self.playerData = PlayerData(playerId: playerId, node: node)
        self.type = powerupType
        self.eventType = eventType
    }

    init?(data: DictionaryModel) {
        guard let playerData = PlayerData(data: data) else {
            return nil
        }
        do {
            let powerupTypeString: String = try data.value(forKey: "type")
            let powerupEventTypeString: String = try data.value(forKey: "eventType")
            guard let type = PowerupType(rawValue: powerupTypeString),
                let eventType = PowerupEventType(rawValue: powerupEventTypeString) else {
                return nil
            }
            guard let eventPosX: Double = try data.value(forKey: "eventPosX"),
                let eventPosY: Double = try data.value(forKey: "eventPosY") else {
                    return nil
            }

            self.type = type
            self.playerData = playerData
            self.eventType = eventType
            self.eventPos = Vector(x: eventPosX, y: eventPosY)
        } catch {
            return nil
        }
    }

    func socketRepresentation() -> SocketData {
        return encoding
    }
}
