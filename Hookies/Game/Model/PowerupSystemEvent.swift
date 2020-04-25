//
//  PowerupSystemEvent.swift
//  Hookies
//
//  Created by JinYing on 14/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

/// The struct that represents the event that is created when the powerupEventType is triggered.
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
