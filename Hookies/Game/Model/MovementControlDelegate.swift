//
//  MovementControlDelegate.swift
//  Hookies
//
//  Created by Jun Wei Koh on 22/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol MovementControlDelegate: Any {
    func movement(isDisabled: Bool, for sprite: SpriteComponent)
}
