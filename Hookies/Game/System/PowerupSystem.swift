//
//  PowerupSystem.swift
//  Hookies
//
//  Created by Jun Wei Koh on 30/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics
import SpriteKit

protocol PowerupSystemProtocol {
//    func addComponent(powerup: PowerupComponent)
//    func steal(powerup: PowerupComponent,
//               from opponent: PlayerEntity,
//               by player: PlayerEntity)
//    func activate(powerup: PowerupComponent)
//    func deactivate(powerup: PowerupComponent,
//                    for player: PlayerEntity)
}

protocol PowerupSystemDelegate: class {
    func hasAddedTrap(sprite: SpriteComponent)
}

class PowerupSystem: System, PowerupSystemProtocol {
    // Key representing the sprite of player and value
    // represent powerup they have
    private var powerups = [SpriteComponent: PowerupComponent]()
    weak var delegate: PowerupSystemDelegate?

    func add(player: PlayerEntity, with powerup: PowerupComponent) {
        guard let playerSprite = getSprite(for: player) else {
                return
        }
        powerups[playerSprite] = powerup
        player.addComponent(powerup)
    }

    func remove(from player: PlayerEntity, powerup: PowerupComponent) {
        guard let playerSprite = getSprite(for: player),
            let powerupIndex = powerups.index(forKey: playerSprite) else {
                return
        }
        guard let indexOfPlayerPowerup = player.components.firstIndex(where: {
            if let playerPowerup = $0 as? PowerupComponent {
                return playerPowerup == powerup
            } else {
                return false
            }
        }) else {
            return
        }

        powerups.remove(at: powerupIndex)
        player.components.remove(at: indexOfPlayerPowerup)
    }

    func activate(powerupType: PowerupType,
                  for sprite: SpriteComponent
    ) -> PowerupComponent? {
        guard let powerup = powerups[sprite] else {
            return nil
        }
        powerup.activatedTime = Date()
        powerup.isActivated = true
        let effects = powerup.parent.getMultiple(PowerupEffectComponent.self)
        for effect in effects {
            apply(effect: effect, by: sprite)
        }
        return powerup
    }

    func deactivate(powerup: PowerupComponent, for player: PlayerEntity) {
        guard let sprite = getSprite(for: player),
            let powerupIndex = powerups.index(forKey: sprite) else {
                return
        }

        let playerPowerups = player.components.compactMap({ $0 as? PowerupComponent })
        if let indexToRemove = playerPowerups.firstIndex(of: powerup) {
            powerups.remove(at: powerupIndex)
            player.components.remove(at: indexToRemove)
        }
    }

    func steal(powerup: PowerupComponent,
               from player1: PlayerEntity,
               by player2: PlayerEntity
    ) {
        guard let powerupToSteal = player1.components
            .compactMap({ $0 as? PowerupComponent }).first else {
                return
        }

        remove(from: player1, powerup: powerupToSteal)
        add(player: player2, with: powerupToSteal)
    }

    private func apply(effect: PowerupEffectComponent,
                       by sprite: SpriteComponent) {
        switch effect {
        case let shield as ShieldEffectComponent:
            applyShieldEffect(shield, by: sprite)
        case let placementEffect as PlacementEffectComponent:
            applyPlacementEffect(placementEffect, by: sprite)
        case let movementEffect as MovementEffectComponent:
            applyMovementEffect(movementEffect, by: sprite)
        default:
            return
        }
    }

    private func applyPlacementEffect(_ effect: PlacementEffectComponent,
                                      by sprite: SpriteComponent) {
        guard let effectSprite = effect.parent.get(SpriteComponent.self) else {
            return
        }
        effectSprite.node.position = sprite.node.position
        delegate?.hasAddedTrap(sprite: effectSprite)
    }

    private func applyMovementEffect(_ effect: MovementEffectComponent,
                                     by sprite: SpriteComponent) {
        guard let initialPoint = effect.from,
            let endPoint = effect.to,
            let duration = effect.duration else {
                return
        }
        sprite.node.position = initialPoint
        let action = SKAction.move(to: endPoint, duration: duration)
        sprite.node.run(action)
    }

    private func applyShieldEffect(_ effect: ShieldEffectComponent,
                                   by sprite: SpriteComponent) {
        let shieldTexture = SKTexture(imageNamed: "shield_bubble")
        let shieldSize = CGSize(width: sprite.node.size.width * 2,
                                height: sprite.node.size.height * 2)
        let shieldNode = SKSpriteNode(texture: shieldTexture,
                                      color: .clear,
                                      size: shieldSize)
        sprite.node.addChild(shieldNode)
        DispatchQueue.main.asyncAfter(deadline: .now() + effect.duration) {
            shieldNode.removeFromParent()
        }
    }
}
