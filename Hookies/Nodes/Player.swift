//
//  Player.swift
//  Hookies
//
//  Created by JinYing on 14/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

struct Player {
    // MARK: - Properties
    private let type = SpriteType.player
    let id: String
    let node: SKSpriteNode
    private(set) var closestBolt: SKSpriteNode
    private(set) var attachedBolt: SKSpriteNode?

    var isAttachedToBolt: Bool {
        return attachedBolt != nil
    }

    // MARK: - Init
    init(id: String, position: CGPoint, imageName: String, closestBolt: SKSpriteNode) {
        self.closestBolt = closestBolt

        self.id = id
        self.node = SKSpriteNode(imageNamed: imageName)
        self.node.zPosition = type.zPosition
        self.node.position = position
        self.node.size = type.size

        guard let texture = self.node.texture else {
            return
        }

        self.node.physicsBody = SKPhysicsBody(texture: texture, size: self.node.size)
        self.node.physicsBody?.isDynamic = type.isDynamic
        self.node.physicsBody?.affectedByGravity = type.affectedByGravity
        self.node.physicsBody?.allowsRotation = type.allowRotation
        self.node.physicsBody?.categoryBitMask = type.bitMask
        self.node.physicsBody?.collisionBitMask = type.collisionBitMask
        self.node.physicsBody?.contactTestBitMask = type.collisionBitMask
    }

    // MARK: - Functions
    func launch(with velocity: CGVector) {
        self.node.physicsBody?.velocity = velocity
    }
}
