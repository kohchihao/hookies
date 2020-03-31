//
//  PowerupComponent.swift
//  Hookies
//
//  Created by Jun Wei Koh on 30/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class PowerupComponent: Component {
    private(set) var parent: Entity
    var isActivated: Bool
    var activatedTime: Date?

    init(parent: Entity) {
        self.parent = parent
        self.isActivated = false
    }
}

// MARK: - Hashable
extension PowerupComponent: Hashable {
    static func == (lhs: PowerupComponent, rhs: PowerupComponent) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}
