//
//  PowerupEvent.swift
//  Hookies
//
//  Created by JinYing on 14/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

protocol PowerupEvent {
    var powerupPos: Vector { get }
    var powerupEventType: PowerupEventType { get }
    var powerupType: PowerupType { get }
}
