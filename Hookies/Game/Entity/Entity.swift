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

    /// To add a component to the entity
    /// - Parameter component: the component to add
    func addComponent(_ component: Component) {
        components.append(component)
    }

    /// Get multiple components of a type from an entity
    /// - Parameter _: the componenet type
    func getMultiple<ComponentType: Component>(_: ComponentType.Type) -> [ComponentType] {
        var result = [ComponentType]()
        for component in components {
            if let typed = component as? ComponentType {
                result.append(typed)
            }
        }
        return result
    }

    /// Get a component from an entity
    /// - Parameter _: the compoenent type
    func get<ComponentType: Component>(_: ComponentType.Type) -> ComponentType? {
        for component in components {
            if let typed = component as? ComponentType {
                return typed
            }
        }
        return nil
    }

    /// To remove the first occurance of a component in an entity
    /// - Parameter component: the component to remove
    func removeFirstComponent(of component: Component) {
        guard let indexToRemove = components
            .firstIndex(where: { $0 === component }) else {
                return
        }
        components.remove(at: indexToRemove)
    }

    /// To remove all components of a type from an entity
    /// - Parameter _: the component type to remove
    func removeComponents<ComponentType: Component>(_: ComponentType.Type) {
        components.removeAll(where: { $0 is ComponentType })
    }
}
