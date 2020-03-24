//
//  File.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class Hook: Component {
    private(set) var parent: Entity
    var hookTo: Entity?

    init(parent: Entity) {
        self.parent = parent
    }
}
