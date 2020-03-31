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
    func setCollectableOnMap(with powerup: PowerupComponent)
    func collect(powerup powerupToCollect: PowerupComponent, by player: PlayerEntity)
}

class CollectableSystem: System, CollectableSystemProtocol {
    private var availablePowerups: [PowerupComponent]
    private var powerupsInMap = [PowerupComponent]()
    private let powerupRespawnDelay = 2.0

    init(powerups: [PowerupComponent]) {
        self.availablePowerups = powerups
    }

    func setCollectableOnMap(with powerup: PowerupComponent) {
        powerupsInMap.append(powerup)
    }

    func collect(powerup powerupToCollect: PowerupComponent, by player: PlayerEntity) {
        player.addComponent(powerupToCollect)
        if let powerupIndex = powerupsInMap.firstIndex(of: powerupToCollect) {
            powerupsInMap.remove(at: powerupIndex)
            player.addComponent(powerupToCollect)
        }
        let newPowerup = generateRandomPowerup()
        DispatchQueue.main.asyncAfter(deadline: .now() + powerupRespawnDelay) {
            self.setCollectableOnMap(with: newPowerup)
        }
    }

    private func generateRandomPowerup() -> PowerupComponent {
        let randomPowerupIndex = Int.random(in: 1..<availablePowerups.count)
        return availablePowerups[randomPowerupIndex]
    }
}
