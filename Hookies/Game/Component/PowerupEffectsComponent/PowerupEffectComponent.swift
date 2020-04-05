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

    init(parent: Entity) {
        self.parent = parent
    }
}
