//
//  PlayerHookEffectSystem.swift
//  Hookies
//
//  Created by Jun Wei Koh on 6/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit

protocol PlayerHookEffectDelegate: MovementControlDelegate, SceneDelegate {

    /// Will be called to confirm whether it is appropriate to hook the sprite
    /// - Parameters:
    ///   - sprite: The sprite to be hooked
    ///   - anchorSprite: The sprite that activates  the hook 
    func toHook(_ sprite: SpriteComponent, from anchorSprite: SpriteComponent)
}

protocol PlayerHookEffectSystemProtocol: EffectSystemProtocol,
    PlayerDenpendencyProtocol {

    /// To hook and pull back the other player's sprite.
    /// - Parameters:
    ///   - sprite: The player's sprite
    ///   - anchorSprite: The other player that is hooked to by `sprite`
    func hookAndPull( _ sprite: SpriteComponent, from anchorSprite: SpriteComponent)
}

class PlayerHookEffectSystem: System, PlayerHookEffectSystemProtocol {
    private let effectType = PlayerHookEffectComponent.self

    var players = [SpriteComponent]()

    weak var delegate: PlayerHookEffectDelegate?

    func update(entities: [PowerupEntity]) {
        let effects = self.getEffectComponents(from: entities, with: effectType)
        for effect in effects {
            applyHook(effect)
            remove(effect: effect)
        }
    }

    private func applyHook(_ effect: PlayerHookEffectComponent) {
        let powerupComponent = effect.parent.get(PowerupComponent.self)
        let owner = powerupComponent?.owner

        guard let ownerSprite = owner?.get(SpriteComponent.self) else {
            return
        }
        guard let spriteToHook = ownerSprite.nearestSpriteInFront(from: players) else {
            Logger.log.show(details: "No players in front to hook", logType: .alert)
            return
        }
        guard !isProtected(spriteComponent: spriteToHook, from: effect) else {
            Logger.log.show(details: "Cannot hook protected player", logType: .alert)
            return
        }

        delegate?.toHook(spriteToHook, from: ownerSprite)
    }

    func hookAndPull(
        _ sprite: SpriteComponent,
        from anchorSprite: SpriteComponent
    ) {
        let line = anchorSprite.makeLine(to: sprite)
        delegate?.hasAdded(node: line)
        delegate?.movement(isDisabled: true, for: sprite)
        sprite.node.physicsBody?.affectedByGravity = false
        sprite.node.physicsBody?.velocity = CGVector.zero
        let duration = TimeInterval(Constants.pullPlayerDuration)

        // The pull animation
        let followAnchor = SKAction.customAction(withDuration: duration) { node, _ in
            let newPath = anchorSprite.makePath(to: sprite)
            line.path = newPath

            let dx = anchorSprite.node.position.x - node.position.x
            let dy = anchorSprite.node.position.y - node.position.y
            let angle = atan2(dx, dy)
            if abs(dx) > Constants.speedOfPlayerPull * 5 {
                node.position.x += sin(angle) * Constants.speedOfPlayerPull
            }
            node.position.y += cos(angle) * Constants.speedOfPlayerPull
        }

        sprite.node.run(followAnchor, completion: {
            line.removeFromParent()
            sprite.node.physicsBody?.affectedByGravity = true
            self.delegate?.movement(isDisabled: false, for: sprite)
        })
    }
}
