//
//  Entity.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol Entity {
    var components: [Component] { get set }
    func addComponent(_ component: Component)
}
