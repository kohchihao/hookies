//
//  MovementControlDelegate.swift
//  Hookies
//
//  Created by Jun Wei Koh on 22/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

/// All delegate that controls the movement for the given sprite.
protocol MovementControlDelegate: AnyObject {

    /// Indicates whether the movement has been disabled for the given sprite
    /// - Parameters:
    ///   - isDisabled: Whether the movement is disabled
    ///   - sprite: The sprite in which the movement is manipulated.
    func movement(isDisabled: Bool, for sprite: SpriteComponent)
}
