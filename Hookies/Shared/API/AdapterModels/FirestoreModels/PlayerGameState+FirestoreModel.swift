//
//  PlayerGameState+FirestoreModel.swift
//  Hookies
//
//  Created by Jun Wei Koh on 16/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Firebase

extension PlayerGameState: FirestoreModel {
    var documentID: String {
        return playerId
    }

    var encoding: [String: Any] {
        return defaultEncoding()
    }

    init?(modelData: FirestoreDataModel) {
        do {
            let position = try Vector(x: modelData.value(forKey: "positionX"),
                                      y: modelData.value(forKey: "positionY"))
            let velocity = try Vector(x: modelData.value(forKey: "velocityX"),
                                      y: modelData.value(forKey: "velocityY"))
            let imageType: String = try modelData.value(forKey: "imageName")
            let lastUpdateTime: Timestamp = try modelData.value(forKey: "lastUpdateTime")
            var attachedPosition: Vector?
            if let attachedToX: Double = modelData.optionalValue(forKey: "attachedPositionX"),
                let attachedToY: Double = modelData.optionalValue(forKey: "attachedPositionY") {
                attachedPosition = Vector(x: attachedToX, y: attachedToY)
            }
            var powerup: Powerup?
            if let powerName: String = modelData.optionalValue(forKey: "powerupName"),
                let isPowerupActivated: Bool = modelData.optionalValue(forKey: "isPowerupActivated") {
                    powerup = PowerupCreator.create(name: powerName, isActivated: isPowerupActivated,
                                                    ownerId: modelData.optionalValue(forKey: "powerupOwnerId"))
            }
            guard let imageName = CostumeType(rawValue: imageType) else {
                return nil
            }

            self.init(
                playerId: modelData.documentID,
                position: position,
                velocity: velocity,
                imageName: imageName,
                lastUpdateTime: lastUpdateTime.dateValue(),
                powerup: powerup,
                attachedPosition: attachedPosition
            )
        } catch {
            return nil
        }
    }
}
