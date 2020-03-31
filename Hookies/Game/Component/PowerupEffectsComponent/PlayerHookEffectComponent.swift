//
//  PlayerHookEffectComponent.swift
//  Hookies
//
//  Created by Jun Wei Koh on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerHookEffectComponent: Component {
    private(set) var parent: Entity
    var hookTo: SpriteComponent?
    var line: SKShapeNode?

    init(parent: Entity) {
        self.parent = parent
    }
}

// MARK: - Hashable
extension PlayerHookEffectComponent: Hashable {
    static func == (lhs: PlayerHookEffectComponent, rhs: PlayerHookEffectComponent) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}
