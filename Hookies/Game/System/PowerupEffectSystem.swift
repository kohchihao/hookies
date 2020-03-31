//
//  PowerupEffectSystem.swift
//  Hookies
//
//  Created by Jun Wei Koh on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit
import CoreGraphics

protocol PowerupEffectSystemProtocol {
    func set(for powerup: PowerupComponent, with effect: Component)
    func applyEffects()
}

class PowerupEffectSystem: System {
    private var players: [SpriteComponent]
    private var shieldEffects = [PowerupComponent: ShieldEffectComponent]()
    private var movementEffects = [PowerupComponent: MovementEffectComponent]()
    private var hookEffects = [PowerupComponent: PlayerHookEffectComponent]()
    private var thiefEffects = [PowerupComponent: ThiefEffectComponent]()
    private var sliceEffects = [PowerupComponent: SliceEffectComponent]()

    init(players: [SpriteComponent]) {
        self.players = players
    }

    func set(for powerup: PowerupComponent, with effect: Component) {
        setShieldEffect(for: powerup, component: effect)
        setMovementEffect(for: powerup, component: effect)
        setHookEffect(for: powerup, component: effect)
        setSliceEffect(for: powerup, component: effect)
        setThiefEffect(for: powerup, component: effect)
    }

    func applyEffects() {
        applyShieldEffects()
        applyMovementEffects()
        applyHookEffects()
    }

    private func applyShieldEffects() {
//        for (powerup, effect) in shields {
//
//        }
    }

    private func applyMovementEffects() {
//        for (powerup, effect) in movements {
//
//        }
    }

    private func applyHookEffects() {
//        for (powerup, effect) in hookEffects {
//
//        }
    }

    private func applySliceEffect() {

    }

    private func applyThiefEffect() {
        
    }

    private func findClosestPlayerInFront(from position: CGPoint) -> SpriteComponent? {
        var closestPlayerInFront: SpriteComponent?
        var closestDistance = Double.greatestFiniteMagnitude
        let positionVector = Vector(point: position)
        for player in players {
            let playerPositionVector = Vector(point: player.node.position)
            let distance = positionVector.distance(to: playerPositionVector)
            if distance > 0 && distance < closestDistance {
                closestDistance = distance
                closestPlayerInFront = player
            }
        }
        return closestPlayerInFront
    }

    private func setShieldEffect(for powerup: PowerupComponent,
                                 component: Component) {
        if let shield = component as? ShieldEffectComponent {
            shieldEffects[powerup] = shield
        }
    }

    private func setMovementEffect(for powerup: PowerupComponent,
                                   component: Component) {
        if let movement = component as? MovementEffectComponent {
            movementEffects[powerup] = movement
        }
    }

    private func setHookEffect(for powerup: PowerupComponent,
                               component: Component) {
        if let hook = component as? PlayerHookEffectComponent {
            hookEffects[powerup] = hook
        }
    }

    private func setThiefEffect(for powerup: PowerupComponent,
                                 component: Component) {
        if let thief = component as? ThiefEffectComponent {
            thiefEffects[powerup] = thief
        }
    }

    private func setSliceEffect(for powerup: PowerupComponent,
                                component: Component) {
        if let slice = component as? SliceEffectComponent {
            sliceEffects[powerup] = slice
        }
    }
}
