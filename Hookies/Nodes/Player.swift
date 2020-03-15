//
//  Player.swift
//  Hookies
//
//  Created by JinYing on 14/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

class Player {
    // MARK: - Properties
    private let type = SpriteType.player
    let id: String
    let node: SKSpriteNode
    var closestBolt: SKSpriteNode
    private(set) var line: SKShapeNode?
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

    func tetherToClosestBolt() {
        line = makeLine(from: node.position, to: closestBolt.position)

        // TODO: Check if anything is in path if line

        attachedBolt = closestBolt
    }

    func updateLine() {
        guard let attachedBolt = attachedBolt, line != nil else {
            return
        }

        line = makeLine(from: node.position, to: attachedBolt.position)
    }

    func releaseFromBolt() {
        line = nil
        attachedBolt = nil
    }

    private func makeLine(from origin: CGPoint, to destination: CGPoint) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: origin)
        path.addLine(to: destination)

        let currLine = SKShapeNode(path: path)
        currLine.strokeColor = SKColor.white
        currLine.lineWidth = 3.0

        return currLine
    }
}
