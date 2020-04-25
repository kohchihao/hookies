//
//  GenericSystemEvent.swift
//  Hookies
//
//  Created by JinYing on 14/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

/// Represent all the Generic System Event in the game
/// - Parameters:
///     - sprite: The SpriteComponent associated to the event
///     - eventType: The type of Generic System Event
struct GenericSystemEvent {
    let sprite: SpriteComponent
    let eventType: GenericPlayerEvent
}
