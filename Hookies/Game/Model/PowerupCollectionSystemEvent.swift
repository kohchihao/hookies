//
//  PowerupCollectionSystemEvent.swift
//  Hookies
//
//  Created by JinYing on 15/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

/// The struct that represents the event that is created when the powerupEventType is triggered.
/// - Parameters:
///     - sprite: The SpriteComponent associated to the event
///     - powerupPos: The position of the powerup that is being collected
///     - powerupType: The type of the powerup that is collected
struct PowerupCollectionSystemEvent {
    let sprite: SpriteComponent
    let powerupPos: Vector
    let powerupType: PowerupType
}
