//
//  PowerupSystemEvent.swift
//  Hookies
//
//  Created by JinYing on 14/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

struct PowerupSystemEvent: SystemEvent, PowerupEvent {
    let sprite: SpriteComponent
    let eventType: GenericPlayerEvent
    let powerupPos: Vector
    let powerupType: PowerupType

    init(sprite: SpriteComponent, eventType: GenericPlayerEvent, powerupPos: Vector, powerupType: PowerupType) {
        self.sprite = sprite
        self.eventType = eventType
        self.powerupPos = powerupPos
        self.powerupType = powerupType
    }
}
