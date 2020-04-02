//
//  Entity.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol Entity: class {
    var components: [Component] { get set }
}

extension Entity {
    func addComponent(_ component: Component) {
        components.append(component)
    }

    func getSpriteComponent() -> SpriteComponent? {
        for component in components {
            if let sprite = component as? SpriteComponent {
                return sprite
            }
        }

        return nil
    }

    func getHookComponent() -> HookComponent? {
        for component in components {
            if let hook = component as? HookComponent {
                return hook
            }
        }

        return nil
    }
}
