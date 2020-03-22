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
    let imageName: CostumeType
    var closestBolt: SKSpriteNode?
    private(set) var line: SKShapeNode?
    private(set) var attachedBolt: SKSpriteNode?
    private var previousAttachedBolt: SKSpriteNode?
    private(set) var powerup: Powerup?

    var isAttachedToBolt: Bool {
        return attachedBolt != nil
    }

    var isStuck = false
    var contactedPlatforms: [SKSpriteNode: Int] = [:]

    // MARK: - Init
    init(id: String, position: CGPoint, imageName: CostumeType, closestBolt: SKSpriteNode?) {
        self.closestBolt = closestBolt

        self.id = id
        self.imageName = imageName
        self.node = SKSpriteNode(imageNamed: imageName.stringValue)
        self.node.zPosition = type.zPosition
        self.node.position = position
        self.node.size = type.size

        self.node.physicsBody = SKPhysicsBody(rectangleOf: self.node.size)
        self.node.physicsBody?.isDynamic = type.initialIsDynamic
        self.node.physicsBody?.mass = type.mass
        self.node.physicsBody?.linearDamping = type.linearDamping
        self.node.physicsBody?.friction = type.friction
        self.node.physicsBody?.affectedByGravity = type.affectedByGravity
        self.node.physicsBody?.allowsRotation = type.allowRotation
        self.node.physicsBody?.categoryBitMask = type.bitMask
        self.node.physicsBody?.collisionBitMask = type.collisionBitMask
        self.node.physicsBody?.contactTestBitMask = type.contactTestBitMask
    }

    init(id: String, position: CGPoint, imageName: CostumeType) {
        self.id = id
        self.imageName = imageName
        self.node = SKSpriteNode(imageNamed: imageName.stringValue)
        self.node.zPosition = type.zPosition
        self.node.position = position
        self.node.size = type.size
    }

    // MARK: - Functions
    func launch(with velocity: CGVector) {
        self.node.physicsBody?.isDynamic = type.isDynamic
        self.node.physicsBody?.velocity = velocity
    }

    func tetherToClosestBolt() {
        guard let closestBolt = closestBolt else {
            return
        }

        let isAttachingToSameBolt = closestBolt.position == previousAttachedBolt?.position

        if isAttachingToSameBolt {
            var positionYOffset = CGFloat(0)

            let isAboveBolt = node.position.y > closestBolt.position.y
            let isBelowBolt = node.position.y < closestBolt.position.y

            if isAboveBolt {
                positionYOffset = CGFloat(-15)
            }

            if isBelowBolt {
                positionYOffset = CGFloat(15)
            }

            node.position = CGPoint(x: node.position.x, y: node.position.y + positionYOffset)
        }

        line = makeLine(to: closestBolt)

        // TODO: Check if anything is in path if line

        self.attachedBolt = closestBolt

        if !isAttachingToSameBolt {
            boostVelocity(withRespectTo: closestBolt)
        }
    }

    func releaseFromBolt() {
        self.previousAttachedBolt = attachedBolt
        self.line = nil
        self.attachedBolt = nil
    }

    func bringToStop() {
        guard let velocity = node.physicsBody?.velocity else {
            return
        }

        let hasPlayerStop = velocity.dx <= 0.5 && velocity.dy <= 0.5

        if !hasPlayerStop {
            let oppositeForce = CGVector(dx: -velocity.dx, dy: -velocity.dy)
            node.physicsBody?.applyForce(oppositeForce)
        } else {
            node.physicsBody?.velocity = CGVector.zero
            node.physicsBody?.restitution = 0
        }
    }

    private func makeLine(to bolt: SKSpriteNode) -> SKShapeNode {
        return makeLine(to: bolt.position)
    }

    private func makeLine(to position: CGPoint) -> SKShapeNode {
        let type = SpriteType.line

        let distanceX = self.node.position.x - position.x
        let distanceY = self.node.position.y - position.y
        let distance = sqrt((distanceX * distanceX) + (distanceY * distanceY))

        let path = CGMutablePath()
        path.move(to: self.node.position)
        path.addLine(to: position)
        path.addLine(to: CGPoint(x: position.x + 1, y: position.y + 1))
        path.addLine(to: CGPoint(x: self.node.position.x - 1, y: self.node.position.y - 1))
        path.closeSubpath()

        let currLine = SKShapeNode(path: path)
        currLine.strokeColor = SKColor.white
        currLine.lineWidth = 1.0

        currLine.physicsBody = SKPhysicsBody(circleOfRadius: distance, center: position)
        currLine.physicsBody?.affectedByGravity = type.affectedByGravity
        currLine.physicsBody?.categoryBitMask = type.bitMask
        currLine.physicsBody?.collisionBitMask = type.collisionBitMask

        return currLine
    }

    private func boostVelocity(withRespectTo bolt: SKSpriteNode) {
        var boostX = 1_000
        let boostY = -1_000

        let isInFrontOfBolt = node.position.x > bolt.position.x

        if isInFrontOfBolt {
            boostX *= -1
        }

        let boost = CGVector(dx: boostX, dy: boostY)
        node.physicsBody?.applyImpulse(boost)
    }

    // MARK: - Render new player frame

    func renderNewFrame(position: CGPoint, attachedBolt: SKSpriteNode?) {
        node.position = position
        self.attachedBolt = attachedBolt

        if let attachedBolt = attachedBolt {
            line = makeLine(to: attachedBolt)
        }
    }

    // MARK: - Checks for deadlock

    func checkIfStuck() {
        guard let physicsBody = node.physicsBody else {
            return
        }

        let isVelocityNearlyZero = isVelocityNearlyZeroDeadlock(physicsBody)
        let isInfiniteBouncing = isInfiniteBouncingDeadlock(physicsBody)

        isStuck = isVelocityNearlyZero || isInfiniteBouncing
    }

    /// Checks for velocity is nearly 0.
    private func isVelocityNearlyZeroDeadlock(_ physicsBody: SKPhysicsBody) -> Bool {
        let playerHorizontalVelocity = physicsBody.velocity.dx
        let isVelocityNearlyZero = playerHorizontalVelocity < CGFloat(0.5)
            && playerHorizontalVelocity > CGFloat(-0.5)
        return isVelocityNearlyZero
    }

    /// Checks for infinite bouncing.
    private func isInfiniteBouncingDeadlock(_ physicsBody: SKPhysicsBody) -> Bool {
        let contactedPhysicsBodies = physicsBody.allContactedBodies()
        for contactedBody in contactedPhysicsBodies {
            guard let spriteNode = contactedBody.node as? SKSpriteNode else {
                return false
            }
            if spriteNode.name == "platform" {
                if let touchCount = contactedPlatforms[spriteNode] {
                    contactedPlatforms[spriteNode] = touchCount + 1
                    if contactedPlatforms[spriteNode] == 10 {
                        contactedPlatforms.removeAll()
                        return true
                    }
                } else {
                    contactedPlatforms[spriteNode] = 1
                }
            }
        }
        return false
    }
}

extension Player: Hashable {
    public static func == (lhs: Player, rhs: Player) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}
