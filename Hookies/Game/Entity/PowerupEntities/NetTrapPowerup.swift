//
//  NetTrapPowerup.swift
//  Hookies
//
//  Created by Jun Wei Koh on 4/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class NetTrapPowerup: PowerupEntity {
    init() {
        super.init(components: [])
        addDefaultComponents(for: .netTrap)
        addComponent(PlacementEffectComponent(parent: self))
    }

    override func activate() {
        super.activate()

        let spriteComponent = SpriteComponent(parent: self)
        spriteComponent.node = PowerupType.netTrap.node
        self.addComponent(spriteComponent)
    }
}
