//
//  PowerupEffectComponent.swift
//  Hookies
//
//  Created by Jun Wei Koh on 4/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit

class PowerupEffectComponent: Component {
    private(set) var parent: Entity

    var isNegativeEffect: Bool // Whether the has negative effect on user
    var duration: Double = 0 // Duration of effect

    init(parent: Entity, isNegativeEffect: Bool) {
        self.parent = parent
        self.isNegativeEffect = isNegativeEffect
    }
}
