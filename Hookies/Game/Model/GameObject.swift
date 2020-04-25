//
//  GameObject.swift
//  Hookies
//
//  Created by JinYing on 12/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

/// Represent all the objects in the game
/// - Parameters:
///     - node: The SKSpriteNode of the GameObject
///     - type: The type of GameObject
struct GameObject {
    let node: SKSpriteNode
    let type: GameObjectType
}
