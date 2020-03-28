//
//  File.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class HookComponent: Component {
    private(set) var parent: Entity
    var hookTo: Entity?

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
