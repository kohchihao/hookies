//
//  CollectableComponent.swift
//  Hookies
//
//  Created by Jun Wei Koh on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics
import SpriteKit

class CollectableComponent: Component {
    private(set) var parent: Entity
    var position: CGPoint
    var isCollected: Bool

    init(parent: Entity, position: CGPoint) {
        self.parent = parent
        self.position = position
        self.isCollected = false
    }
}

enum CollectableType: String, CaseIterable {
    case powerup
}
