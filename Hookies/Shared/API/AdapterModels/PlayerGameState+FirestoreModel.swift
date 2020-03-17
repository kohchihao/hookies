//
//  PlayerGameState+FirestoreModel.swift
//  Hookies
//
//  Created by Jun Wei Koh on 16/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

extension PlayerGameState: FirestoreModel {
    var documentID: String {
        return playerId
    }

    var serialized: [String: Any?] {
        return defaultSerializer()
    }

    init?(modelData: FirestoreModelData) {
        do {
            let position = try Vector(x: modelData.value(forKey: "positionX"),
                                      y: modelData.value(forKey: "positionY"))
            let velocity = try Vector(x: modelData.value(forKey: "velocityX"),
                                      y: modelData.value(forKey: "velocityY"))
            let powerup = try PowerupCreator.create(name: modelData.value(forKey: "powerupName"),
                                                    isActivated: modelData.value(forKey: "isPowerupActivated"),
                                                    ownerId: modelData.optionalValue(forKey: "powerupOwnerId"))
            var attachedPosition: Vector?
            if let attachedToX: Double = modelData.optionalValue(forKey: "attachedToX"),
                let attachedToY: Double = modelData.optionalValue(forKey: "attachedToY") {
                attachedPosition = Vector(x: attachedToX, y: attachedToY)
            }

            self.init(
                playerId: modelData.documentID,
                position: position,
                velocity: velocity,
                powerup: powerup,
                attachedPosition: attachedPosition
            )
        } catch {
            return nil
        }
    }
}
