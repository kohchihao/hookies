//
//  Rotate.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class RotateComponent: Component {
    private(set) var parent: Entity
    var omega: Double = 0.0

    init(parent: Entity) {
        self.parent = parent
    }
}
