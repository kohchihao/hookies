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

    func removeComponent(at index: Int) {
        components.remove(at: index)
    }
}
