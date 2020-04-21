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
}

extension PowerupEntity {
    static func create(for type: PowerupType,
                       at position: CGPoint
    ) -> PowerupEntity {
        let powerup = PowerupEntity()
        let powerupSprite = SpriteComponent(parent: powerup)
        let powerupComponent = PowerupComponent(parent: powerup,
                                                type: type)
        powerup.addComponent(powerupSprite)
        powerup.addComponent(powerupComponent)
        return powerup
    }

    func addEffectComponents(for type: PowerupType) {
        removeComponents(PowerupEffectComponent.self)
        addComponents(for: type)
        addActivatedSpriteIfExist()
    }

    private func addActivatedSpriteIfExist() {
        guard let powerupComponent = self.get(PowerupComponent.self) else {
            return
        }

        switch powerupComponent.type {
        case .netTrap:
            let spriteComponent = SpriteComponent(parent: self)
            spriteComponent.node = PowerupType.netTrap.node
            self.addComponent(spriteComponent)
        default:
            return
        }
    }

    private func addComponents(for type: PowerupType) {
        switch type {
        case .cutHook:
            addCutHookComponents()
        case .netTrap:
            addNetTrapComponents()
        case .playerHook:
            addPlayerHookComponents()
        case .shield:
            addShieldComponents()
        case .stealPowerup:
            addStealComponents()
        }
    }

    private func addCutHookComponents() {
        let movementEffect = MovementEffectComponent(parent: self)
        let playerHookEffect = PlayerHookEffectComponent(parent: self)
        addComponent(movementEffect)
        addComponent(playerHookEffect)
    }

    private func addNetTrapComponents() {
        let placementComponent = PlacementEffectComponent(parent: self)
        addComponent(placementComponent)
    }

    private func addPlayerHookComponents() {
        let movementEffect = MovementEffectComponent(parent: self)
        let playerHookEffect = PlayerHookEffectComponent(parent: self)
        addComponent(movementEffect)
        addComponent(playerHookEffect)
    }

    private func addShieldComponents() {
        let shieldEffect = ShieldEffectComponent(parent: self)
        addComponent(shieldEffect)
    }

    private func addStealComponents() {
        let thiefEffect = ThiefEffectComponent(parent: self)
        addComponent(thiefEffect)
    }
}
