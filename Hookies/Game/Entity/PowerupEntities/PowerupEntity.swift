//
//  PowerupEntity.swift
//  Hookies
//
//  Created by Jun Wei Koh on 3/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

class PowerupEntity: Entity {
    var components: [Component]

    init(components: [Component]) {
        self.components = components
    }

    convenience init() {
        self.init(components: [])
    }

    /// Create a powerup entity of random type
    static func createWithRandomType() -> PowerupEntity {
        let randType = PowerupType.allCases.randomElement() ?? .shield
        return create(for: randType)
    }

    /// A factory that is used to create a powerup entity of a given type
    /// - Parameter type: The type of powerup entity to create
    static func create(for type: PowerupType) -> PowerupEntity {
        let powerup: PowerupEntity
        switch type {
        case .cutRope:
            powerup = CutRopePowerup()
        case .netTrap:
            powerup = NetTrapPowerup()
        case .playerHook:
            powerup = PlayerHookPowerup()
        case .shield:
            powerup = ShieldPowerup()
        case .stealPowerup:
            powerup = StealPowerup()
        }
        powerup.addInitialComponents(for: type)
        return powerup
    }

    /// Add the initial components related to powerup entities.
    /// - Parameter type: The type of the powerup
    func addInitialComponents(for type: PowerupType) {
        let powerupSprite = SpriteComponent(parent: self)
        let powerupComponent = PowerupComponent(parent: self, type: type)
        addComponent(powerupSprite)
        addComponent(powerupComponent)
    }

    /// Will create a new powerup entity that has the same initial state as the existing one.
    /// But with a different type
    /// - Parameter type: The type of powerup entity to create to create
    func sync(with type: PowerupType) -> PowerupEntity? {
        guard let existingSpriteComponent = get(SpriteComponent.self) else {
            return nil
        }

        let newPowerupEntity = PowerupEntity.create(for: type)
        let powerupComponent = PowerupComponent(parent: newPowerupEntity,
                                                type: type)
        let spriteComponent = SpriteComponent(parent: newPowerupEntity)
        spriteComponent.node = existingSpriteComponent.node

        newPowerupEntity.components.removeAll(where: {
            !($0 is PowerupEffectComponent)
        })
        newPowerupEntity.addComponent(powerupComponent)
        newPowerupEntity.addComponent(spriteComponent)
        return newPowerupEntity
    }

    /// Will activate the powerup entity
    func activate() {
        guard let powerupComponent = get(PowerupComponent.self) else {
            return
        }
        powerupComponent.isActivated = true
    }
}
