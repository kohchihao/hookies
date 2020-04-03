//
//  Bounce.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class BounceComponent: Component {
    private(set) var parent: Entity
    var restitution = 0.0

    init(parent: Entity) {
        self.parent = parent
    }
}

// MARK: - Hashable
extension BounceComponent: Hashable {
    static func == (lhs: BounceComponent, rhs: BounceComponent) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}
