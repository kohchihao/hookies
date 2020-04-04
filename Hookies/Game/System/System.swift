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
    func getSprite(for entity: Entity) -> SpriteComponent? {
        for component in entity.components {
            if let sprite = component as? SpriteComponent {
                return sprite
            }
        }

        return nil
    }

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
