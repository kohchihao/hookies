//
//  Bounce.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class Bounce: Component {
    private(set) var parent: Entity
    var restitution = 0.0

    init(parent: Entity) {
        self.parent = parent
    }
}
