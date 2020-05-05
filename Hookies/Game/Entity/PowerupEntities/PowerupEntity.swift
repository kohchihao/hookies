//
//  PowerupEntity.swift
//  Hookies
//
//  Created by Jun Wei Koh on 3/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

class PowerupEntity: Entity {
    var components: [Component]

    init(components: [Component]) {
        self.components = components
    }

    convenience init(for type: PowerupType) {
        self.init(components: [])
        addDefaultComponents(for: type)
    }

    func addDefaultComponents(for type: PowerupType) {
        let powerupSprite = SpriteComponent(parent: self)
        let powerupComponent = PowerupComponent(parent: self, type: type)
        addComponent(powerupSprite)
        addComponent(powerupComponent)
    }

    static func createRandom() -> PowerupEntity {
        let randType = PowerupType.allCases.randomElement() ?? .shield
        return create(for: randType)
    }

    static func create(for type: PowerupType) -> PowerupEntity {
        switch type {
        case .cutRope:
            return CutRopePowerup()
        case .netTrap:
            return NetTrapPowerup()
        case .playerHook:
            return PlayerHookPowerup()
        case .shield:
            return ShieldPowerup()
        case .stealPowerup:
            return StealPowerup()
        }
    }

    func activate() {
        guard let powerupComponent = get(PowerupComponent.self) else {
            return
        }
        powerupComponent.isActivated = true
    }
}

extension PowerupEntity {
    /// Will add the respective effect for the given type.
    func addEffectComponents(for type: PowerupType) {
        addComponents(for: type)
        addActivatedSpriteIfExist()
    }

    /// If there exist a sprite associated to the activated sprite, then add it into the entity.
    private func addActivatedSpriteIfExist() {
        guard let powerupComponent = self.get(PowerupComponent.self) else {
            return
        }

        switch powerupComponent.type {
        case .netTrap:
            let spriteComponent = SpriteComponent(parent: self)
            spriteComponent.node = PowerupType.netTrap.node
            self.addComponent(spriteComponent)
        default:
            return
        }
    }

    private func addComponents(for type: PowerupType) {
        switch type {
        case .cutRope:
            addCutRopeComponents()
        case .netTrap:
            addNetTrapComponents()
        case .playerHook:
            addPlayerHookComponents()
        case .shield:
            addShieldComponents()
        case .stealPowerup:
            addStealComponents()
        }
    }

    private func addCutRopeComponents() {
        let cutRopeEffect = CutRopeEffectComponent(parent: self)
        addComponent(cutRopeEffect)
    }

    private func addNetTrapComponents() {
        let placementComponent = PlacementEffectComponent(parent: self)
        addComponent(placementComponent)
    }

    private func addPlayerHookComponents() {
        let playerHookEffect = PlayerHookEffectComponent(parent: self)
        addComponent(playerHookEffect)
    }

    private func addShieldComponents() {
        let shieldEffect = ShieldEffectComponent(parent: self)
        addComponent(shieldEffect)
    }

    private func addStealComponents() {
        let stealPowerupEffect = StealPowerupEffectComponent(parent: self)
        addComponent(stealPowerupEffect)
    }
}
