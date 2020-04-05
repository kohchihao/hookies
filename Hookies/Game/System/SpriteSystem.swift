//
//  SpriteSystem.swift
//  Hookies
//
//  Created by JinYing on 28/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

/// Only manages the creating and updating of sprite attributes

protocol SpriteSystemProtocol {
    func set(
        sprite: SpriteComponent,
        of type: SpriteType,
        with imageName: String,
        at position: CGPoint
    ) -> SpriteComponent
    func setPhysicsBody(
        to sprite: SpriteComponent,
        of type: SpriteType,
        rectangleOf size: CGSize
    ) -> SpriteComponent
    func setPhysicsBody(
        to sprite: SpriteComponent,
        of type: SpriteType,
        circleOfRadius radius: CGFloat
    ) -> SpriteComponent
    func setPhysicsBody(
        to sprite: SpriteComponent,
        of type: SpriteType,
        circleOfRadius radius: CGFloat,
        center: CGPoint
    ) -> SpriteComponent
    func removePhysicsBody(to sprite: SpriteComponent)
}

class SpriteSystem: System, SpriteSystemProtocol {
    func set(
        sprite: SpriteComponent,
        of type: SpriteType,
        with imageName: String,
        at position: CGPoint
    ) -> SpriteComponent {
        sprite.node = SKSpriteNode(imageNamed: imageName)
        sprite.node.position = position
        sprite.node.zPosition = type.zPosition
        sprite.node.size = type.size

        return sprite
    }

    func set(sprite: SpriteComponent, to node: SKSpriteNode) -> SpriteComponent {
        sprite.node = node
        return sprite
    }

    func setPhysicsBody(
        to sprite: SpriteComponent,
        of type: SpriteType
    ) -> SpriteComponent {
        sprite.node.physicsBody = SKPhysicsBody()
        return setPhysicsBodyProperties(to: sprite, of: type)
    }

    func setPhysicsBody(
        to sprite: SpriteComponent,
        of type: SpriteType,
        rectangleOf size: CGSize
    ) -> SpriteComponent {
        sprite.node.physicsBody = SKPhysicsBody(rectangleOf: size)
        return setPhysicsBodyProperties(to: sprite, of: type)
    }

    func setPhysicsBody(
        to sprite: SpriteComponent,
        of type: SpriteType,
        circleOfRadius radius: CGFloat
    ) -> SpriteComponent {
        sprite.node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        return setPhysicsBodyProperties(to: sprite, of: type)
    }

    func setPhysicsBody(
        to sprite: SpriteComponent,
        of type: SpriteType,
        circleOfRadius radius: CGFloat,
        center: CGPoint
    ) -> SpriteComponent {
        sprite.node.physicsBody = SKPhysicsBody(circleOfRadius: radius, center: center)

        return setPhysicsBodyProperties(to: sprite, of: type)
    }

    func removePhysicsBody(to sprite: SpriteComponent) {
        sprite.node.physicsBody = nil
    }

    private func setPhysicsBodyProperties(to sprite: SpriteComponent, of type: SpriteType) -> SpriteComponent {
        sprite.node.physicsBody?.isDynamic = type.isDynamic
        sprite.node.physicsBody?.affectedByGravity = type.affectedByGravity
        sprite.node.physicsBody?.allowsRotation = type.allowRotation
        sprite.node.physicsBody?.mass = type.mass
        sprite.node.physicsBody?.linearDamping = type.linearDamping
        sprite.node.physicsBody?.friction = type.friction
        sprite.node.physicsBody?.categoryBitMask = type.bitMask
        sprite.node.physicsBody?.collisionBitMask = type.collisionBitMask
        sprite.node.physicsBody?.contactTestBitMask = type.contactTestBitMask

        return sprite
    }
}
