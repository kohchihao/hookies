//
//  PositionData.swift
//  Hookies
//
//  Created by Jun Wei Koh on 1/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import CoreGraphics
import SocketIO
import SpriteKit

struct PlayerData: SocketData, Encoder {
    var encoding: [String: Any] {
        return defaultEncoding()
    }

    let playerId: String
    let position: Vector
    var velocity: Vector?

    init(playerId: String, position: Vector, velocity: Vector?) {
        self.playerId = playerId
        self.position = position
        self.velocity = velocity
    }

    init(playerId: String, node: SKSpriteNode) {
        self.playerId = playerId
        self.position = Vector(point: node.position)
        self.velocity = Vector(vector: node.physicsBody?.velocity)
    }

    init?(data: DictionaryModel) {
        do {
            self.playerId = try data.value(forKey: "playerId")
            self.position = Vector(x: try data.value(forKey: "positionX") as Double,
                                   y: try data.value(forKey: "positionY") as Double)
            if let velocityX: Double = data.optionalValue(forKey: "velocityX"),
                let velocityY: Double = data.optionalValue(forKey: "velocityY") {
                    self.velocity = Vector(x: velocityX, y: velocityY)
            }
        } catch {
            return nil
        }
    }

    func socketRepresentation() -> SocketData {
        return encoding
    }
}
