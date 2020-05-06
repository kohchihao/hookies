//
//  PlacementEffectSystem.swift
//  Hookies
//
//  Created by Jun Wei Koh on 6/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol PlacementEffectSystemDelegate: AnyObject {
    /// Indicates that the trap has been added.
    /// - Parameter sprite: The trap's sprite
    func hasAddedTrap(sprite: SpriteComponent)
}
protocol PlacementEffectSystemProtocol: EffectSystemProtocol {}

class PlacementEffectSystem: PlacementEffectSystemProtocol {
    private let effectType = PlacementEffectComponent.self

    weak var delegate: PlacementEffectSystemDelegate?

    func update(entities: [PowerupEntity]) {
        let effects = getEffectComponents(from: entities, with: effectType)
        effects.forEach({
            apply(effect: $0)
            remove(effect: $0)
        })
    }

    private func apply(effect: PlacementEffectComponent) {
        let powerup = effect.parent.get(PowerupComponent.self)
        let owner = powerup?.owner
        guard let ownerSprite = owner?.get(SpriteComponent.self) else {
            return
        }
        applyPlacementEffect(effect, by: ownerSprite)
    }

    private func applyPlacementEffect(_ effect: PlacementEffectComponent,
                                      by sprite: SpriteComponent) {
        guard let effectSprite = effect.parent.get(SpriteComponent.self) else {
            return
        }

        effectSprite.node.position = sprite.node.position
        delegate?.hasAddedTrap(sprite: effectSprite)
    }}
