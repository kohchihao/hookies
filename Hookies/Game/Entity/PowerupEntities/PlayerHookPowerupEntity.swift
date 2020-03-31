//
//  PlayerHookPowerup.swift
//  Hookies
//
//  Created by Jun Wei Koh on 30/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class PlayerHookPowerupEntity: Entity {
    var components: [Component]

    init(components: [Component]) {
        self.components = components
    }

    convenience init() {
        self.init(components: [])
    }
}
