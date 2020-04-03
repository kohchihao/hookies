//
//  ClosestBoltSystem.swift
//  Hookies
//
//  Created by Marcus Koh on 30/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit

/// Represents the closest bolt to the given position.

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

    func findClosestBolt(to position: CGPoint) -> (PreviousClosestBoltSprite?, CurrentClosestBoltSprite?) {
        previousClosestBoltSprite = currentClosestBoltSprite
        var closestDistance = Double.greatestFiniteMagnitude
        let otherEntityPosition = Vector(point: position)
        let normalBoltTexture = SKTexture(imageNamed: "bubble_1")
        let closestBoltTexture = SKTexture(imageNamed: "bubble_3")

        for bolt in boltSpriteComponents {
            let boltPositionVector = Vector(point: bolt.node.position)
            let distance = (boltPositionVector - otherEntityPosition).magnitude
            closestDistance = min(Double(distance), closestDistance)
            if closestDistance == Double(distance) {
                currentClosestBoltSprite = bolt
                previousClosestBoltSprite?.node.texture = normalBoltTexture
                currentClosestBoltSprite?.node.texture = closestBoltTexture
                return (previousClosestBoltSprite, currentClosestBoltSprite)
            }
        }

        previousClosestBoltSprite?.node.texture = normalBoltTexture
        currentClosestBoltSprite?.node.texture = closestBoltTexture
        return (previousClosestBoltSprite, currentClosestBoltSprite)
    }
}
