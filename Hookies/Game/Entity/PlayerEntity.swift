//
//  PlayerEntity.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class PlayerEntity: Entity {
    var components: [Component]

    init(components: [Component]) {
        self.components = components
    }

    convenience init() {
        self.init(components: [])

        let hook = HookComponent(parent: self)
        let sprite = SpriteComponent(parent: self)

        addComponent(hook)
        addComponent(sprite)
    }
}
