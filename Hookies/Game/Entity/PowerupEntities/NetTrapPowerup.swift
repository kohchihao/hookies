//
//  NetTrapPowerup.swift
//  Hookies
//
//  Created by Jun Wei Koh on 4/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//
import Foundation

class NetTrapPowerup: PowerupEntity, TrapEntity {
    init() {
        super.init(components: [])
        addInitialComponents(for: .netTrap)
    }

    override func activate() {
        super.activate()
        addComponent(PlacementEffectComponent(parent: self))
        addNetTrapSprite()
    }

    func activateTrap(on sprite: SpriteComponent) {
        guard let trapSprite = get(SpriteComponent.self) else {
            return
        }

        let movementComponent = MovementEffectComponent(parent: sprite.parent,
                                                        isNegativeEffect: true)
        movementComponent.duration = 5.0
        movementComponent.from = trapSprite.node.position
        movementComponent.to = trapSprite.node.position
        movementComponent.stopMovement = true
        sprite.parent.addComponent(movementComponent)
    }

    private func addNetTrapSprite() {
        let spriteComponent = SpriteComponent(parent: self)
        spriteComponent.node = PowerupType.netTrap.node
        self.addComponent(spriteComponent)
    }
}
