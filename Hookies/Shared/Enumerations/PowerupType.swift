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
    case cutRope = "cut_rope"
    case netTrap = "net_trap"

    /// The String that represents the name of the powerup button image
    var buttonString: String {
        return self.rawValue + "_button"
    }

    /// The node that represents this  powerup type
    var node: SKSpriteNode {
        let netTrapTexture = SKTexture(imageNamed: self.rawValue)
        let size = CGSize(width: 50, height: 50)
        let node = SKSpriteNode(texture: netTrapTexture,
                                color: .clear,
                                size: size)
        return node
    }

    /// The button node that is used by this powerup type.
    var buttonNode: SKSpriteNode {
        let texture = SKTexture(imageNamed: self.buttonString)
        let sizeOfPowerup = CGSize(width: 50, height: 50)
        let powerupDisplay = SKSpriteNode(texture: texture,
                                          color: .clear,
                                          size: sizeOfPowerup)
        return powerupDisplay
    }

    var stringValue: String {
        return rawValue
    }

    func animateRemoval(from position: CGPoint) -> SKSpriteNode {
        let powerupDisplay = buttonNode
        powerupDisplay.position = position
        powerupDisplay.zPosition = 0

        let finalPosition = CGPoint(x: powerupDisplay.position.x,
                                    y: powerupDisplay.position.y + 60)
        let powerupAnimation = SKAction.sequence([SKAction.move(to: finalPosition, duration: 1),
                                                  SKAction.fadeOut(withDuration: 0.5)])
        powerupDisplay.run(powerupAnimation, completion: {
            powerupDisplay.removeFromParent()
        })
        return powerupDisplay
    }
}
