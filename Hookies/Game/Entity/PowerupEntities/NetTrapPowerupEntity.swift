//
//  NetTrapPowerup.swift
//  Hookies
//
//  Created by Jun Wei Koh on 4/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//
import Foundation

class NetTrapPowerup: PowerupEntity {
    init() {
        super.init(components: [])
        addInitialComponents(for: .netTrap)
        addComponent(PlacementEffectComponent(parent: self))
    }

    override func activate() {
        super.activate()
        addNetTrapSprite()
    }

    override func postActivationHook() {
        super.postActivationHook()
        addMovementEffect()
    }

    private func addNetTrapSprite() {
        let spriteComponent = SpriteComponent(parent: self)
        spriteComponent.node = PowerupType.netTrap.node
        self.addComponent(spriteComponent)
    }

    private func addMovementEffect() {
        let powerupComponent = get(PowerupComponent.self)
        let owner = powerupComponent?.owner
        guard let ownerSprite = owner?.get(SpriteComponent.self) else {
            return
        }

        let movementComponent = MovementEffectComponent(parent: self,
                                                        isNegativeEffect: true)
        movementComponent.duration = 5.0
        movementComponent.from = ownerSprite.node.position
        movementComponent.to = ownerSprite.node.position
        movementComponent.stopMovement = true
        self.addComponent(movementComponent)
    }
}
