//
//  CutRopeEffect.swift
//  Hookies
//
//  Created by Jun Wei Koh on 22/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

enum CutRopeStrategy {
    case allPlayers
    case nearestFrontPlayer
}

class CutRopeEffectComponent: PowerupEffectComponent {
    var strategy = CutRopeStrategy.allPlayers

    init(parent: Entity) {
        super.init(parent: parent, isNegativeEffect: true)
    }
}
