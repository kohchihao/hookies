//
//  PowerupSystemEvent.swift
//  Hookies
//
//  Created by JinYing on 14/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

/// The struct that represents the event that is created when the powerupEventType is triggered.
/// - Parameters:
///     - sprite: The SpriteComponent associated to the event
///     - powerupEventType: The powerup event type
///     - powerupType: The type of the powerup
///     - powerupPos: The position of the powerup in which the event occur
struct PowerupSystemEvent {
    let sprite: SpriteComponent
    let powerupEventType: PowerupEventType
    let powerupType: PowerupType
    let powerupPos: Vector

    init(sprite: SpriteComponent,
         powerupEventType: PowerupEventType,
         powerupType: PowerupType,
         powerupPos: Vector? = nil
    ) {
        self.sprite = sprite
        self.powerupType = powerupType
        self.powerupEventType = powerupEventType
        if powerupPos == nil {
            self.powerupPos = Vector(point: sprite.node.position)
        } else {
            self.powerupPos = powerupPos!
        }
    }
}
