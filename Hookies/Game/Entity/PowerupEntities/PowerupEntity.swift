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

    static func createWithRandomType() -> PowerupEntity {
        let randType = PowerupType.allCases.randomElement() ?? .shield
        return create(for: randType)
    }

    static func create(for type: PowerupType) -> PowerupEntity {
        switch type {
        case .cutRope:
            return CutRopePowerup()
        case .netTrap:
            return NetTrapPowerup()
        case .playerHook:
            return PlayerHookPowerup()
        case .shield:
            return ShieldPowerup()
        case .stealPowerup:
            return StealPowerup()
        }
    }

    func addInitialComponents(for type: PowerupType) {
        let powerupSprite = SpriteComponent(parent: self)
        let powerupComponent = PowerupComponent(parent: self, type: type)
        addComponent(powerupSprite)
        addComponent(powerupComponent)
    }

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

    func activate() {
        guard let powerupComponent = get(PowerupComponent.self) else {
            return
        }
        powerupComponent.isActivated = true
    }

    func getMaxEffectDuration() -> Double {
        var result = 0.0
        getMultiple(PowerupEffectComponent.self).forEach({
            result = max($0.duration, result)
        })
        return result
    }
}
