//
//  StealEffectSystem.swift
//  Hookies
//
//  Created by Jun Wei Koh on 7/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol StealEffectSystemDelegate: AnyObject {
    /// Indicates that steal has occurred.
    /// - Parameters:
    ///   - sprite: The sprite that was stolen from
    ///   - sprite: The sprite that stole
    ///   - powerup: The power up stolen
    func didSteal(from sprite1: SpriteComponent,
                  by sprite2: SpriteComponent,
                  with powerup: PowerupComponent
    )
}

protocol StealEffectSystemProtocol: EffectSystemProtocol,
    PlayerDependencyProtocol {}

class StealEffectSystem: System, StealEffectSystemProtocol {
    private let effectType = StealPowerupEffectComponent.self
    var players = [SpriteComponent]()
    var powerups = [PowerupEntity]()

    weak var delegate: StealEffectSystemDelegate?

    func apply(on powerups: [PowerupEntity]) {
        self.powerups = powerups
        let effects = getEffectComponents(from: powerups, with: effectType)
        effects.forEach({
            apply(effect: $0)
            remove(effect: $0)
        })
    }

    private func apply(effect: StealPowerupEffectComponent) {
        let owner = effect.parent.get(PowerupComponent.self)?.owner
        guard let ownerSprite = owner?.get(SpriteComponent.self) else {
            return
        }
        applyStealPowerupEffect(effect, by: ownerSprite)
    }

    private func applyStealPowerupEffect(_ effect: StealPowerupEffectComponent,
                                         by sprite: SpriteComponent) {
        guard let nearestSprite = sprite.nearestSpriteInFront(from: players) else {
            Logger.log.show(details: "No players in front to steal powerup",
                            logType: .warning)
            return
        }
        guard !isProtected(spriteComponent: nearestSprite, from: effect) else {
            Logger.log.show(details: "Cannot steal from shielded player.",
                            logType: .warning)
            return
        }
        guard let powerupToSteal = getOwnedPowerupOf(sprite: nearestSprite) else {
            Logger.log.show(details: "No Powerup to steal", logType: .alert)
            return
        }
        delegate?.didSteal(from: nearestSprite, by: sprite, with: powerupToSteal)
    }

    private func getOwnedPowerupOf(sprite: SpriteComponent) -> PowerupComponent? {
        for powerup in powerups {
            let owner = powerup.get(PowerupComponent.self)?.owner
            guard let powerupComponent = powerup.get(PowerupComponent.self) else {
                continue
            }
            if owner?.get(SpriteComponent.self) === sprite &&
                !powerupComponent.isActivated {
                return powerupComponent
            }
        }
        return nil
    }
}
