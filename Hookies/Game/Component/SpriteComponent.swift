//
//  Sprite.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit

class SpriteComponent: Component {
    private(set) var parent: Entity
    var node = SKSpriteNode()

    init(parent: Entity) {
        self.parent = parent
    }
}

// MARK: - Hashable
extension SpriteComponent: Hashable {
    static func == (lhs: SpriteComponent, rhs: SpriteComponent) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}

extension SpriteComponent {
    func makeLine(to sprite2: SpriteComponent) -> SKShapeNode {
        let type = SpriteType.line

        let distance = Vector(point: node.position).distance(to: Vector(point: sprite2.node.position))

        let path = makePath(to: sprite2)

        let currLine = SKShapeNode(path: path)
        currLine.strokeColor = SKColor.white
        currLine.lineWidth = 1.0

        currLine.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(distance), center: sprite2.node.position)
        currLine.physicsBody?.affectedByGravity = type.affectedByGravity
        currLine.physicsBody?.categoryBitMask = type.bitMask
        currLine.physicsBody?.collisionBitMask = type.collisionBitMask

        return currLine
    }

    func makePath(to sprite2: SpriteComponent) -> CGMutablePath {
        let path = CGMutablePath()
        path.move(to: node.position)
        path.addLine(to: sprite2.node.position)
        path.addLine(to: CGPoint(x: sprite2.node.position.x + 1, y: sprite2.node.position.y + 1))
        path.addLine(to: CGPoint(x: node.position.x - 1, y: node.position.y - 1))
        path.closeSubpath()
        return path
    }

    func distance(to sprite2: SpriteComponent) -> CGFloat {
        let sprite1Pos = Vector(point: node.position)
        let sprite2Pos = Vector(point: sprite2.node.position)
        return CGFloat(sprite1Pos.distance(to: sprite2Pos))
    }

    func nearestSpriteInFront(from others: [SpriteComponent]) -> SpriteComponent? {
        var nearestSprite: SpriteComponent?
        var nearestDistance = CGFloat.greatestFiniteMagnitude
        let spritePos = node.position
        let maxHookDistance = UIScreen.main.bounds.width

        for currentSprite in others {
            if currentSprite === self {
                continue
            }
            let currentEucDist = currentSprite.distance(to: self)
            let currentXDist = currentSprite.node.position.x - spritePos.x
            if currentXDist <= 0 || currentEucDist > maxHookDistance {
                continue
            }

            if currentEucDist < nearestDistance {
                nearestDistance = currentEucDist
                nearestSprite = currentSprite
            }
        }
        return nearestSprite
    }
}
