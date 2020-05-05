//
//  PowerupCollectableComponent.swift
//  Hookies
//
//  Created by Jun Wei Koh on 5/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit

class PowerupCollectableComponent: CollectableComponent {
    var parent: Entity

    required init(parent: Entity) {
        self.parent = parent
    }

    func collect(with delegate: CollectableDelegate?) {
        let powerup = PowerupEntity.createRandom()
        guard let powerupComponent = powerup.get(PowerupComponent.self),
            let collectableSprite = parent.get(SpriteComponent.self) else {
            return
        }
        let powerupType = powerupComponent.type
        let powerupDisplay = powerupType.buttonNode

        powerupDisplay.position = collectableSprite.node.position
        powerupDisplay.zPosition = 0

        let finalPosition = CGPoint(x: powerupDisplay.position.x,
                                    y: powerupDisplay.position.y + 60)
        let powerupAnimation = SKAction.sequence([SKAction.move(to: finalPosition, duration: 1),
                                                  SKAction.fadeOut(withDuration: 0.5)])
        powerupDisplay.run(powerupAnimation, completion: {
            powerupDisplay.removeFromParent()
            delegate?.didCollect(powerup: powerupComponent)
        })
        delegate?.didAnimate(for: powerupDisplay)
    }
}
