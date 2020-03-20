//
//  Cannon.swift
//  Hookies
//
//  Created by JinYing on 14/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

struct Cannon {
    // MARK: - Properties
    let node: SKSpriteNode

    // MARK: - Init
    init(node: SKSpriteNode) {
        self.node = node
    }

    // MARK: - Methods
    func launch(player: Player, with velocity: CGVector) {
        player.launch(with: velocity)
    }
}
