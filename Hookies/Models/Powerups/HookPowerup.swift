//
//  HookPowerup.swift
//  Hookies
//
//  Created by Jun Wei Koh on 17/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

struct HookPowerup: Powerup {
    var ownerId: String?
    var isActivated: Bool

    init(isActivated: Bool, ownerId: String? = nil) {
        self.isActivated = isActivated
        self.ownerId = ownerId
    }

    mutating func activate(by user: User) {
        isActivated = true
    }

    mutating func deactivate() {
        isActivated = false
    }
}
