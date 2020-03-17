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
            let attachedPosition = try Vector(x: modelData.value(forKey: "attachedToX"),
                                              y: modelData.value(forKey: "attachedToY"))
            let powerupState = "idle"

            self.init(
                playerId: modelData.documentID,
                position: position,
                velocity: velocity,
                powerupState: powerupState,
                attachedPosition: attachedPosition
            )
        } catch {
            return nil
        }
    }
}
