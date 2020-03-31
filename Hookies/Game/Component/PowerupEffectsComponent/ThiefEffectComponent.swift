//
//  ThiefEffectComponent.swift
//  Hookies
//
//  Created by Jun Wei Koh on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics

class ThiefEffectComponent: Component {
    private(set) var parent: Entity
    var position: CGPoint?

    init(parent: Entity) {
        self.parent = parent
    }
}

// MARK: - Hashable
extension ThiefEffectComponent: Hashable {
    static func == (lhs: ThiefEffectComponent,
                    rhs: ThiefEffectComponent
    ) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}
