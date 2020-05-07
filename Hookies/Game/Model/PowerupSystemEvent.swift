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
///     - powerupPos: The position of the powerup in which this event took place
struct PowerupSystemEvent {
    let sprite: SpriteComponent
    let powerupEventType: PowerupEventType
    let powerupPos: Vector

    init(sprite: SpriteComponent,
         powerupEventType: PowerupEventType,
         powerupPos: Vector
    ) {
        self.sprite = sprite
        self.powerupEventType = powerupEventType
        self.powerupPos = powerupPos
    }
}
