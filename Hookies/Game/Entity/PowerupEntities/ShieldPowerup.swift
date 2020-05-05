//
//  ShieldPowerup.swift
//  Hookies
//
//  Created by Jun Wei Koh on 4/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class ShieldPowerup: PowerupEntity {
    init() {
        super.init(components: [])
        addDefaultComponents(for: .shield)
        addComponent(ShieldEffectComponent(parent: self))
    }
}
