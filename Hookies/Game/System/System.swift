//
//  System.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol System {
}

extension System {

    /// Gets a compoennt from an entity
    /// - Parameters:
    ///     - _: the component type to get
    ///     - entity: the entity to get the component from
    func get<ComponentType: Component>(_: ComponentType.Type,
                                       for entity: Entity
    ) -> ComponentType? {
        for component in entity.components {
            if let typed = component as? ComponentType {
                return typed
            }
        }
        return nil
    }
}
