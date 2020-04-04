//
//  CollectableSystem.swift
//  Hookies
//
//  Created by Jun Wei Koh on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics
import SpriteKit

protocol CollectableSystemProtocol {
//    func setCollectableOnMap(with powerup: PowerupComponent)
//    func collect(powerup powerupToCollect: PowerupComponent, by player: PlayerEntity)
}

class CollectableSystem: System, CollectableSystemProtocol {
    /// The key will represent the sprite of the powerup while the value represents the actual powerup component
    private var powerups = [SpriteComponent: PowerupComponent]()

    func set(for sprite: SpriteComponent, with powerup: PowerupComponent) {
        powerups[sprite] = powerup
    }

    func removePowerup(for sprite: SpriteComponent) {
        guard let index = powerups.index(forKey: sprite) else {
            return
        }
        powerups.remove(at: index)
    }

    func collect(powerup: PowerupEntity, playerId: String) -> PowerupComponent? {
        print(powerup.components)
        guard let powerupSprite = getSprite(for: powerup),
            let powerupComponent = get(PowerupComponent.self, for: powerup),
            let powerupIndex = powerups.index(forKey: powerupSprite) else {
                return nil
        }

        // Remove Sprite components because they are no longer needed as a sprite
        powerup.components.removeAll(where: { $0 is SpriteComponent })
        PowerupEntity.addActivatedSpriteIfExist(powerup: powerup)
        powerups.remove(at: powerupIndex)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        powerupSprite.node.run(fade, completion: {
            powerupSprite.node.removeFromParent()
        })
        powerupComponent.setOwner(id: playerId)
        return powerupComponent
    }
}
