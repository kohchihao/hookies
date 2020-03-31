//
//  CannonEntity.swift
//  Hookies
//
//  Created by JinYing on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class CannonEntity: Entity {
    var components: [Component]

    init(components: [Component]) {
        self.components = components
    }

    convenience init() {
        self.init(components: [])
    }
}
