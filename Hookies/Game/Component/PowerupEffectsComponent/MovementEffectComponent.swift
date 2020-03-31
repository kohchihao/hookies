//
//  NetTrapEffectComponent.swift
//  Hookies
//
//  Created by Jun Wei Koh on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics

class MovementEffectComponent: Component {
    private(set) var parent: Entity
    var from: CGPoint?
    var to: CGPoint?
    var duration: CGFloat?

    init(parent: Entity) {
        self.parent = parent
    }
}

// MARK: - Hashable
extension MovementEffectComponent: Hashable {
    static func == (lhs: MovementEffectComponent,
                    rhs: MovementEffectComponent
    ) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}
