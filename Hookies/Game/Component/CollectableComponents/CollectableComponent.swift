//
//  CollectableComponent.swift
//  Hookies
//
//  Created by Jun Wei Koh on 4/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol CollectableComponent: Component {
    /// Will animate the collection of the collectable
    func collect(with delegate: CollectableDelegate?)
}
