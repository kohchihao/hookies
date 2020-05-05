//
//  CollectablePowerupEntity.swift
//  Hookies
//
//  Created by Jun Wei Koh on 5/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class TreasureBoxEntity: Entity {
    var components: [Component]
    // A list of components that the player can get from the treasure box
    private let collectableTypes = [PowerupCollectableComponent.self]

    init(components: [Component]) {
        self.components = components
    }

    convenience init() {
        self.init(components: [])

        let sprite = SpriteComponent(parent: self)
        let collectableType = collectableTypes.randomElement() ?? PowerupCollectableComponent.self

        let collectable = collectableType.init(parent: self)

        addComponent(sprite)
        addComponent(collectable)
    }
}
