//
//  Sprite.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit

class SpriteComponent: Component {
    private(set) var parent: Entity
    var node = SKSpriteNode()

    init(parent: Entity) {
        self.parent = parent
    }
}

// MARK: - Hashable
extension SpriteComponent: Hashable {
    static func == (lhs: SpriteComponent, rhs: SpriteComponent) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}
