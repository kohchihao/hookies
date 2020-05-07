//
//  StealPowerup.swift
//  Hookies
//
//  Created by Jun Wei Koh on 4/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//
import Foundation

class StealPowerup: PowerupEntity {
    init() {
        super.init(components: [])
        addInitialComponents(for: .stealPowerup)
    }

    override func activate() {
        super.activate()
        addComponent(StealPowerupEffectComponent(parent: self))
    }
}
