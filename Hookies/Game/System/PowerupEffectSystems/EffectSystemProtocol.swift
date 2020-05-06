//
//  EffectSystemProtocol.swift
//  Hookies
//
//  Created by Jun Wei Koh on 6/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol EffectSystemProtocol {
    func update(entities: [PowerupEntity])
}

extension EffectSystemProtocol {
    func getEffectComponents<T: PowerupEffectComponent>(
        from entities: [PowerupEntity],
        with type: T.Type
    ) -> [T] {
        var effects = [T]()
        for entity in entities {
            if let effect = entity.get(T.self) {
                effects.append(effect)
            }
        }
        return effects
    }

    /// Determine whether the sprite is protected from the given effect
    func isProtected(spriteComponent: SpriteComponent,
                     from effect: PowerupEffectComponent
    ) -> Bool {
        guard spriteComponent.parent.get(ShieldEffectComponent.self) != nil else {
            return false
        }
        return effect.isNegativeEffect
    }

    func remove(effect: PowerupEffectComponent) {
        effect.parent.removeFirstComponent(of: effect)
    }
}
