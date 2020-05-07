//
//  CutHookPowerup.swift
//  Hookies
//
//  Created by Jun Wei Koh on 4/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//
import Foundation

class CutRopePowerup: PowerupEntity {
    override func activate() {
        super.activate()
        addComponent(CutRopeEffectComponent(parent: self))
    }
}
