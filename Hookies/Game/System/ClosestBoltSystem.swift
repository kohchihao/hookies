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
        for bolt in boltSpriteComponents {
            let boltPositionVector = Vector(point: bolt.node.position)
            let distance = (boltPositionVector - otherEntityPosition).magnitude
            closestDistance = min(Double(distance), closestDistance)
            if closestDistance == Double(distance) {
                currentClosestBoltSprite = bolt
                return (previousClosestBoltSprite, currentClosestBoltSprite)
            }
        }

        return (previousClosestBoltSprite, currentClosestBoltSprite)
    }
}
