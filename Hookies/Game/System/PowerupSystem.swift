//
//  PowerupSystem.swift
//  Hookies
//
//  Created by Jun Wei Koh on 30/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics

protocol PowerupSystemProtocol {
    func addComponent(powerup: PowerupComponent)
    func steal(powerup: PowerupComponent,
               from opponent: PlayerEntity,
               by player: PlayerEntity)
    func activate(powerup: PowerupComponent)
    func deactivate(powerup: PowerupComponent,
                    for player: PlayerEntity)
}

class PowerupSystem: System, PowerupSystemProtocol {
    private var players: [PlayerEntity]
    private var powerupComponents: Set<PowerupComponent>

    init(players: [PlayerEntity]) {
        self.players = players
        self.powerupComponents = Set()
    }

    func addComponent(powerup: PowerupComponent) {
        powerupComponents.insert(powerup)
    }

    func steal(powerup: PowerupComponent,
               from opponent: PlayerEntity,
               by player: PlayerEntity
    ) {
        var oppPowerups = opponent
            .components.compactMap({ $0 as? PowerupComponent })
        let powerupToSteal = oppPowerups.removeFirst()
        player.components.append(powerupToSteal)
        opponent.components = oppPowerups
    }

    func activate(powerup: PowerupComponent) {
        guard let powerup = powerupComponents.first(where: { $0 == powerup }) else {
            return
        }
        powerup.activatedTime = Date()
        powerup.isActivated = true
    }

    func deactivate(powerup: PowerupComponent, for player: PlayerEntity) {
        guard powerupComponents.contains(powerup) else {
            return
        }

        let playerPowerups = player.components.compactMap({ $0 as? PowerupComponent })
        if let indexToRemove = playerPowerups.firstIndex(of: powerup) {
            powerupComponents.remove(powerup)
            player.components.remove(at: indexToRemove)
        }
    }
}
