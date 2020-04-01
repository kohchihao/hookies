//
//  PositionData.swift
//  Hookies
//
//  Created by Jun Wei Koh on 1/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import CoreGraphics
import SocketIO

struct PlayerData: SocketData, Encoder {
    var encoding: [String: Any] {
        return defaultEncoding()
    }

    let playerId: String
    let position: CGPoint
    var velocity: CGVector?

    init(playerId: String, position: CGPoint, velocity: CGVector?) {
        self.playerId = playerId
        self.position = position
        self.velocity = velocity
    }

    init?(data: DictionaryModel) {
        do {
            self.playerId = try data.value(forKey: "playerId")
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
