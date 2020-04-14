//
//  SystemEvent.swift
//  Hookies
//
//  Created by JinYing on 14/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

protocol SystemEvent {
    var sprite: SpriteComponent { get }
    var eventType: GenericPlayerEvent { get }
}
