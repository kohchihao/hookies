//
//  PowerupComponent.swift
//  Hookies
//
//  Created by Jun Wei Koh on 30/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class PowerupComponent: Component {
    private(set) var parent: Entity
    var owner: PlayerEntity?
    var isActivated: Bool
    var type: PowerupType

    init(parent: Entity, type: PowerupType) {
        self.parent = parent
        self.isActivated = false
        self.type = type
    }

    /// Set owner of the powerup.
    /// - Parameter player: The player's entity that own the powerup
    func setOwner(_ player: Entity) {
        guard let playerEntity = player as? PlayerEntity else {
            return
        }
        owner = playerEntity
    }
}

// MARK: - Hashable
extension PowerupComponent: Hashable {
    static func == (lhs: PowerupComponent, rhs: PowerupComponent) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}
