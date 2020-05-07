//
//  PlayerHookPowerup.swift
//  Hookies
//
//  Created by Jun Wei Koh on 4/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//
import Foundation

class PlayerHookPowerup: PowerupEntity {
    override func activate() {
        super.activate()
        addComponent(PlayerHookEffectComponent(parent: self))

        let cutRopeEffect = CutRopeEffectComponent(parent: self)
        addComponent(cutRopeEffect)
        cutRopeEffect.strategy = .nearestFrontPlayer
    }
}
