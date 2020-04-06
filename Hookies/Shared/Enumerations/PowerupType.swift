//
//  PowerupType.swift
//  Hookies
//
//  Created by Jun Wei Koh on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit

enum PowerupType: String, CaseIterable, StringRepresentable {
    case playerHook = "player_hook"
    case stealPowerup = "steal_powerup"
    case shield
    case cutHook = "cut_hook"
    case netTrap = "net_trap"

    var buttonString: String {
        return self.rawValue + "_button"
    }

    var node: SKSpriteNode {
        let netTrapTexture = SKTexture(imageNamed: self.rawValue)
        let size = CGSize(width: 50, height: 50)
        let node = SKSpriteNode(texture: netTrapTexture,
                                color: .clear,
                                size: size)
        return node
    }

    var stringValue: String {
        return rawValue
    }
}
