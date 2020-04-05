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

    convenience init() {
        self.init(components: [])
    }
}

extension PowerupEntity {
    static func createSpecializedEntity(for type: PowerupType
    ) -> PowerupEntity {
        switch type {
        case .cutHook:
            return createCutHookEntity()
        case .netTrap:
            return createNetTrapEntity()
        case .playerHook:
            return createPlayerHookEntity()
        case .shield:
            return createShieldEntity()
        case .stealPowerup:
            return createStealPowerupEntity()
        }
    }

    static func addActivatedSpriteIfExist(powerup: PowerupEntity) {
        if powerup is NetTrapPowerupEntity {
            let spriteComponent = SpriteComponent(parent: powerup)
            spriteComponent.node = PowerupType.netTrap.node
            powerup.addComponent(spriteComponent)
        }
    }

    private static func createCutHookEntity() -> CutHookPowerupEntity {
        let cutHookEntity = CutHookPowerupEntity()
        let movementEffect = MovementEffectComponent(parent: cutHookEntity)
        let playerHookEffect = PlayerHookEffectComponent(parent: cutHookEntity)
        cutHookEntity.addComponent(movementEffect)
        cutHookEntity.addComponent(playerHookEffect)
        return cutHookEntity
    }

    private static func createNetTrapEntity() -> NetTrapPowerupEntity {
        let netTrap = NetTrapPowerupEntity()
        let placementComponent = PlacementEffectComponent(parent: netTrap)

        netTrap.addComponent(placementComponent)
        return netTrap
    }

    private static func createPlayerHookEntity() -> PlayerHookPowerupEntity {
        let playerHook = PlayerHookPowerupEntity()
        let movementEffect = MovementEffectComponent(parent: playerHook)
        let playerHookEffect = PlayerHookEffectComponent(parent: playerHook)
        playerHook.addComponent(movementEffect)
        playerHook.addComponent(playerHookEffect)
        return playerHook
    }

    private static func createShieldEntity() -> ShieldPowerupEntity {
        let shield = ShieldPowerupEntity()
        let shieldEffect = ShieldEffectComponent(parent: shield)
        shield.addComponent(shieldEffect)
        return shield
    }

    private static func createStealPowerupEntity() -> StealPowerupEntity {
        let steal = StealPowerupEntity()
        let thiefEffect = ThiefEffectComponent(parent: steal)
        steal.addComponent(thiefEffect)
        return steal
    }
}
