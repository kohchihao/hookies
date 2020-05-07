//
//  MovementEffectSystem.swift
//  Hookies
//
//  Created by Jun Wei Koh on 6/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

protocol MovementEffectSystemDelegate: MovementControlDelegate {}
protocol MovementEffectSystemProtocol: EffectSystemProtocol, PlayerDependencyProtocol {}

class MovementEffectSystem: MovementEffectSystemProtocol {
    var players = [SpriteComponent]()

    private let effectType = MovementEffectComponent.self

    weak var delegate: MovementEffectSystemDelegate?

    func update(entities: [PowerupEntity]) {
        let playerEntities = players.compactMap({ $0.parent as? PlayerEntity })
        let effects = getEffectComponents(from: entities + playerEntities,
                                          with: effectType)
        effects.forEach({
            apply(effect: $0)
            remove(effect: $0)
        })
    }

    private func apply(effect: MovementEffectComponent) {
        guard let affectedSprite = effect.parent.get(SpriteComponent.self) else {
            return
        }
        applyMovementEffect(effect, on: affectedSprite)
    }

    private func applyMovementEffect(_ effect: MovementEffectComponent,
                                     on sprite: SpriteComponent) {
        guard !isProtected(spriteComponent: sprite, from: effect) else {
            return
        }

        guard let initialPoint = effect.from,
            let endPoint = effect.to else {
                return
        }

        delegate?.movement(isDisabled: true, for: sprite)
        if effect.stopMovement {
            sprite.node.physicsBody?.velocity = CGVector.zero
            sprite.node.physicsBody?.affectedByGravity = false
        }

        sprite.node.position = initialPoint
        let action = SKAction.move(to: endPoint, duration: effect.duration)

        sprite.node.run(action, completion: {
            sprite.node.physicsBody?.affectedByGravity = true
            self.delegate?.movement(isDisabled: false, for: sprite)
        })
    }
}
