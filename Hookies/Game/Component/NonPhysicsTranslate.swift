//
//  NonPhysicsTranslate.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics

class NonPhysicsTranslate: Component {
    private(set) var parent: Entity
    var path = CGMutablePath()

    init(parent: Entity) {
        self.parent = parent
    }
}
