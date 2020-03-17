//
//  PowerupCreator.swift
//  Hookies
//
//  Created by Jun Wei Koh on 17/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

struct PowerupCreator {
    static func create(name: String, isActivated: Bool, ownerId: String? = nil) -> Powerup? {
        switch name {
        case HookPowerup.name:
            return HookPowerup(isActivated: isActivated, ownerId: ownerId)
        default:
            return nil
        }
    }
}
