//
//  NonPhysicsTranslate.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics

class NonPhysicsTranslateComponent: Component {
    private(set) var parent: Entity
    var path = CGMutablePath()

    init(parent: Entity) {
        self.parent = parent
    }
}

// MARK: - Hashable
extension NonPhysicsTranslateComponent: Hashable {
    static func == (lhs: NonPhysicsTranslateComponent, rhs: NonPhysicsTranslateComponent) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}
