//
//  PlayerHookPowerup.swift
//  Hookies
//
//  Created by Jun Wei Koh on 4/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//
import Foundation

class PlayerHookPowerup: PowerupEntity {
    init() {
        super.init(components: [])
        addInitialComponents(for: .playerHook)
    }

    override func activate() {
        super.activate()
        addComponent(PlayerHookEffectComponent(parent: self))
    }
}
