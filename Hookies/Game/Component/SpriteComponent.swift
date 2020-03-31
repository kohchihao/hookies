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

        let path = CGMutablePath()
        path.move(to: node.position)
        path.addLine(to: sprite2.node.position)
        path.addLine(to: CGPoint(x: sprite2.node.position.x + 1, y: sprite2.node.position.y + 1))
        path.addLine(to: CGPoint(x: node.position.x - 1, y: node.position.y - 1))
        path.closeSubpath()

        let currLine = SKShapeNode(path: path)
        currLine.strokeColor = SKColor.white
        currLine.lineWidth = 1.0

        currLine.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(distance), center: sprite2.node.position)
        currLine.physicsBody?.affectedByGravity = type.affectedByGravity
        currLine.physicsBody?.categoryBitMask = type.bitMask
        currLine.physicsBody?.collisionBitMask = type.collisionBitMask

        return currLine
    }

    func makeAnchor(from sprite: SpriteComponent) -> SKNode {
        let anchor = SKNode()
        anchor.position = sprite.node.position
        anchor.physicsBody = SKPhysicsBody()
        anchor.physicsBody?.isDynamic = false

        return anchor
    }
}
