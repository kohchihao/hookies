//
//  ShieldEffect.swift
//  Hookies
//
//  Created by Jun Wei Koh on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics

class ShieldEffectComponent: PowerupEffectComponent {
    init(parent: Entity) {
        super.init(parent: parent, isNegativeEffect: false)
        duration = 3.0
    }
}
