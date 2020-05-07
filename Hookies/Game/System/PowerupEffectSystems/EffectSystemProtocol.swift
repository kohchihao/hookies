//
//  EffectSystemProtocol.swift
//  Hookies
//
//  Created by Jun Wei Koh on 6/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol EffectSystemProtocol {
    func apply(on powerups: [PowerupEntity])
}

extension EffectSystemProtocol {
    func getEffectComponents<T: PowerupEffectComponent>(
        from entities: [Entity],
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

    func remove(effect: PowerupEffectComponent) {
        effect.parent.removeFirstComponent(of: effect)
    }
}
