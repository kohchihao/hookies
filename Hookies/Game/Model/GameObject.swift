//
//  GameObject.swift
//  Hookies
//
//  Created by JinYing on 12/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

struct GameObject {
    let node: SKSpriteNode
    let type: GameObjectType

    init(node: SKSpriteNode, type: GameObjectType) {
        self.node = node
        self.type = type
    }
}
