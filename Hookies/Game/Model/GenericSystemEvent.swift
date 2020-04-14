//
//  GenericSystemEvent.swift
//  Hookies
//
//  Created by JinYing on 14/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

struct GenericSystemEvent: SystemEvent {
    let sprite: SpriteComponent
    let eventType: GenericPlayerEvent

    init(sprite: SpriteComponent, eventType: GenericPlayerEvent) {
        self.sprite = sprite
        self.eventType = eventType
    }
}
