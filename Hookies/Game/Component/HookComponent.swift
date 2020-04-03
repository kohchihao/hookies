//
//  File.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

class HookComponent: Component {
    private(set) var parent: Entity
    var hookTo: SpriteComponent?
    var prevHookTo: SpriteComponent?
    var anchor: SKNode?
    var line: SKShapeNode?
    var anchorLineJointPin: SKPhysicsJointPin?
    var parentLineJointPin: SKPhysicsJointPin?

    init(parent: Entity) {
        self.parent = parent
    }
}

// MARK: - Hashable
extension HookComponent: Hashable {
    static func == (lhs: HookComponent, rhs: HookComponent) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}
