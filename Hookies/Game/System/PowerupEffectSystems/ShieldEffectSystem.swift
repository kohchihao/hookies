//
//  ShieldEffectSystem.swift
//  Hookies
//
//  Created by Jun Wei Koh on 6/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

protocol ShieldEffectSystemProtocol: EffectSystemProtocol {}

class ShieldEffectSystem: System, ShieldEffectSystemProtocol {
    private let effectType = ShieldEffectComponent.self

    func apply(on powerups: [PowerupEntity]) {
        let effects = getEffectComponents(from: powerups, with: effectType)
        for effect in effects {
            applyShieldEffect(effect)
            remove(effect: effect)
        }
    }

    private func applyShieldEffect(_ effect: ShieldEffectComponent) {
        let owner = effect.parent.get(PowerupComponent.self)?.owner
        guard let ownerSprite = owner?.get(SpriteComponent.self) else {
            return
        }

        let shieldTexture = SKTexture(imageNamed: "shield_bubble")
        let shieldSize = CGSize(width: ownerSprite.node.size.width * 2,
                                height: ownerSprite.node.size.height * 2)
        let shieldNode = SKSpriteNode(texture: shieldTexture,
                                      color: .clear,
                                      size: shieldSize)
        ownerSprite.node.addChild(shieldNode)
        ownerSprite.parent.addComponent(effect)

        DispatchQueue.main.asyncAfter(deadline: .now() + effect.duration) {
            shieldNode.removeFromParent()
            ownerSprite.parent.removeFirstComponent(of: effect)
        }
    }
}
