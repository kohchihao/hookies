//
//  ClosestBoltSystem.swift
//  Hookies
//
//  Created by Marcus Koh on 30/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit

/// Closest Bolt System helps to find the closest bolt.

typealias PreviousClosestBoltSprite = SpriteComponent
typealias CurrentClosestBoltSprite = SpriteComponent

protocol ClosestBoltSystemProtocol {
    func findClosestBolt(to position: CGPoint) -> (PreviousClosestBoltSprite?, CurrentClosestBoltSprite?)
}

class ClosestBoltSystem: System, ClosestBoltSystemProtocol {

    private var previousClosestBoltSprite: PreviousClosestBoltSprite?
    private var currentClosestBoltSprite: CurrentClosestBoltSprite?
    private let boltSpriteComponents: [SpriteComponent]

    init(bolts: [SpriteComponent]) {
        self.boltSpriteComponents = bolts
    }

    /// Finds the closest bolt from a given position.
    /// - Parameters:
    ///   - position: The position of the sprite
    func findClosestBolt(to position: CGPoint) -> (PreviousClosestBoltSprite?, CurrentClosestBoltSprite?) {
        var closestDistance = Double.greatestFiniteMagnitude
        let otherEntityPosition = Vector(point: position)
        let normalBoltTexture = SKTexture(imageNamed: "bubble_1")
        let closestBoltTexture = SKTexture(imageNamed: "bubble_3")

        for bolt in boltSpriteComponents {
            let boltPositionVector = Vector(point: bolt.node.position)
            let distance = boltPositionVector.distance(to: otherEntityPosition)
            closestDistance = min(Double(distance), closestDistance)
            // Checks if the minimum selected is the distance
            if closestDistance == Double(distance) {
                previousClosestBoltSprite = currentClosestBoltSprite
                currentClosestBoltSprite = bolt
                previousClosestBoltSprite?.node.texture = normalBoltTexture
                currentClosestBoltSprite?.node.texture = closestBoltTexture
            }
        }

        return (previousClosestBoltSprite, currentClosestBoltSprite)
    }
}
