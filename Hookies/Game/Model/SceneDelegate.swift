//
//  SceneDelegate.swift
//  Hookies
//
//  Created by Jun Wei Koh on 5/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

protocol SceneDelegate {

    /// Will be called when the given node is to be added into the UI
    /// - Parameter node: The node to be added into the game scene.
    func hasAdded(node: SKSpriteNode)
}
