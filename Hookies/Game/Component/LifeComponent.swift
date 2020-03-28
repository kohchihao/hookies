//
//  Life.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class LifeComponent: Component {
    private(set) var parent: Entity
    var isDead = false

    init(parent: Entity) {
        self.parent = parent
    }
}

// MARK: - Hashable
extension LifeComponent: Hashable {
    static func == (lhs: LifeComponent, rhs: LifeComponent) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}
