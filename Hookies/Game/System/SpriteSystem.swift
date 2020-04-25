//
//  SpriteSystem.swift
//  Hookies
//
//  Created by JinYing on 28/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

/// Sprite system manages the creating and updating of sprite attributes.

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

    /// Set the sprite with its attribute.
    /// - Parameters:
    ///   - sprite: The sprite component to set
    ///   - type: The type of sprite
    ///   - imageName: The image of the sprite
    ///   - position: The position of the sprite
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

    /// Set the sprite attributes.
    /// - Parameters:
    ///   - sprite: The sprite component to set
    ///   - node: The node to set to the sprite
    func set(sprite: SpriteComponent, to node: SKSpriteNode) -> SpriteComponent {
        sprite.node = node
        return sprite
    }

    /// Set the physics body for the sprite.
    /// - Parameters:
    ///   - sprite: The sprite component to set
    ///   - type: The type of sprite
    func setPhysicsBody(
        to sprite: SpriteComponent,
        of type: SpriteType
    ) -> SpriteComponent {
        sprite.node.physicsBody = SKPhysicsBody()
        return setPhysicsBodyProperties(to: sprite, of: type)
    }

    /// Set the rectangle physics body for the sprite
    /// - Parameters:
    ///   - sprite: The sprite component to set
    ///   - type: The type of sprite
    ///   - size: The size of the rectangle
    func setPhysicsBody(
        to sprite: SpriteComponent,
        of type: SpriteType,
        rectangleOf size: CGSize
    ) -> SpriteComponent {
        sprite.node.physicsBody = SKPhysicsBody(rectangleOf: size)
        return setPhysicsBodyProperties(to: sprite, of: type)
    }

    /// Set the circular physics body for the sprite
    /// - Parameters:
    ///   - sprite: The sprite component to set
    ///   - type: The type of sprite
    ///   - radius: The radius of the ciruclar
    func setPhysicsBody(
        to sprite: SpriteComponent,
        of type: SpriteType,
        circleOfRadius radius: CGFloat
    ) -> SpriteComponent {
        sprite.node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        return setPhysicsBodyProperties(to: sprite, of: type)
    }

    /// Set the circular physics body for the sprite.
    /// - Parameters:
    ///   - sprite: The sprite component to set
    ///   - type: The type of sprite
    ///   - radius: The radius of the ciruclar
    func setPhysicsBody(
        to sprite: SpriteComponent,
        of type: SpriteType,
        circleOfRadius radius: CGFloat,
        center: CGPoint
    ) -> SpriteComponent {
        sprite.node.physicsBody = SKPhysicsBody(circleOfRadius: radius, center: center)

        return setPhysicsBodyProperties(to: sprite, of: type)
    }

    /// Remove the physics body for the sprite.
    /// - Parameter sprite: The sprite to remove the physics body
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
