//
//  PlayerHookEffectComponent.swift
//  Hookies
//
//  Created by Jun Wei Koh on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerHookEffectComponent: PowerupEffectComponent {

    init(parent: Entity) {
        super.init(parent: parent, isNegativeEffect: true)
    }
}
