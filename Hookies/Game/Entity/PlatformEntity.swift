//
//  Platform.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class PlatformEntity: Entity {
    var components: [Component]

    init(components: [Component]) {
        self.components = components
    }

    convenience init() {
        self.init(components: [])

        let sprite = SpriteComponent(parent: self)
        let translate = NonPhysicsTranslateComponent(parent: self)
        let rotate = RotateComponent(parent: self)

        addComponent(sprite)
        addComponent(translate)
        addComponent(rotate)
    }
}
