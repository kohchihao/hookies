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

    func getMultiple<ComponentType: Component>(_: ComponentType.Type) -> [ComponentType] {
        var result = [ComponentType]()
        for component in components {
            if let typed = component as? ComponentType {
                result.append(typed)
            }
        }
        return result
    }

    func get<ComponentType: Component>(_: ComponentType.Type) -> ComponentType? {
        for component in components {
            if let typed = component as? ComponentType {
                return typed
            }
        }
        return nil
    }

    func removeComponents<ComponentType: Component>(_: ComponentType.Type) {
        components.removeAll(where: { $0 is ComponentType })
    }
}
