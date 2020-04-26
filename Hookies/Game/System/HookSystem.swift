//
//  HookSystem.swift
//  Hookies
//
//  Created by JinYing on 28/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

/// Hook System handles the hooking, unhooking, shortening and lengthening action for the players.

enum HookSystemAction {
    case lengthen, shorten
}

typealias AboveBoltDisplacement = Double
typealias BelowBoltDisplacement = Double
typealias RightBoltDisplacement = Double
typealias LeftBoltDisplacement = Double

protocol HookSystemProtocol {
    func hook(from hook: Entity) -> Bool
    func unhook(entity: Entity) -> Bool
    func unhook(entity: Entity, at position: CGPoint,
                with velocity: CGVector) -> Bool
    func applyInitialVelocity(sprite: SpriteComponent, velocity: CGVector)
    func boostVelocity(to entity: Entity)
    func hookAndPull(_ sprite: SpriteComponent,
                     from anchorSprite: SpriteComponent)
}

protocol HookSystemDelegate: MovementControlDelegate {
    /// Indicates that a hook has been applied by a sprite,
    /// - Parameters:
    ///   - sprite: The sprite that applied the hook action
    ///   - velocity: The iniial velocity of the sprite
    ///   - hook: The hook component for the sprte
    func hookActionApplied(sprite: SpriteComponent, velocity: CGVector, hook: HookComponent)

    /// Indicaties that an adjust hook has been applied by a sprite
    /// - Parameters:
    ///   - sprite: The sprite that applied the adjust action
    ///   - velocity: The initial velocity of the sprite
    ///   - hook: the hook compoennt for the sprite
    func adjustHookActionApplied(sprite: SpriteComponent, velocity: CGVector, hook: HookComponent)

    /// Indicates that an unhook acton has been applieed
    /// - Parameter hook: The hook component to unhook from
    func unhookActionApplied(hook: HookComponent)

    /// Indicates that a hook player action has been applied
    /// - Parameter line: The line between the 2 players
    func hookPlayerApplied(with line: SKShapeNode)
}

class HookSystem: System, HookSystemProtocol {
    private var hooks: Set<HookComponent>
    private var bolts: [SpriteComponent]
    private var players = [SpriteComponent]()
    private let minRopeLength = 100.0

    weak var delegate: HookSystemDelegate?

    init(bolts: [SpriteComponent]) {
        self.hooks = Set<HookComponent>()
        self.bolts = bolts

        registerNotificationObservers()
    }

    // MARK: - Add Player

    /// Add the player to the system that can hook.
    /// - Parameter player: The player sprite
    func add(player: SpriteComponent) {
        players.append(player)
    }

    // MARK: - Hook

    /// The player hooking to a bolt.
    /// - Parameter entity: The player's entity that is hooking to a bolt
    func hook(from entity: Entity) -> Bool {
        guard let sprite = entity.get(SpriteComponent.self), let velocity = sprite.node.physicsBody?.velocity else {
            return false
        }

        broadcast(with: sprite, of: .hook)
        return hook(from: entity, at: sprite.node.position, with: velocity)
    }

    /// The other player hooking to a bolt.
    /// - Parameters:
    ///   - entity: The other player's entity
    ///   - position: The position of the other player
    ///   - velocity: The velocity of the other player
    private func hook(from entity: Entity, at position: CGPoint, with velocity: CGVector) -> Bool {
        guard let sprite = entity.get(SpriteComponent.self),
            let hook = entity.get(HookComponent.self)
            else {
            return false
        }

        sprite.node.position = position
        sprite.node.physicsBody?.velocity = velocity

        guard let closestBolt = findClosestBolt(from: sprite.node.position) else {
            return false
        }

        let line = sprite.makeLine(to: closestBolt)

        // To ensure that the joint pin between bolt-line and player-line should be created
        guard let anchorLineJointPin = makeJointPinToLine(from: closestBolt.node, toLine: line),
            let spriteLineJointPin = makeJointPinToLine(from: sprite.node, toLine: line) else {
                return false
        }

        hook.hookTo = closestBolt
        hook.line = line
        hook.anchorLineJointPin = anchorLineJointPin
        hook.parentLineJointPin = spriteLineJointPin

        delegate?.hookActionApplied(sprite: sprite, velocity: velocity, hook: hook)

        return true
    }

    /// To hook and pull back the other player's sprite.
    /// - Parameters:
    ///   - sprite: The player's sprite
    ///   - anchorSprite: The other player that is hooked to by `sprite`
    func hookAndPull(_ sprite: SpriteComponent, from anchorSprite: SpriteComponent) {
        guard let sprite = anchorSprite.nearestSpriteInFront(from: players) else {
            Logger.log.show(details: "No sprite found in the front", logType: .warning)
            return
        }
        let line = anchorSprite.makeLine(to: sprite)
        delegate?.hookPlayerApplied(with: line)
        delegate?.movement(isDisabled: true, for: sprite)
        sprite.node.physicsBody?.affectedByGravity = false
        sprite.node.physicsBody?.velocity = CGVector.zero
        let duration = TimeInterval(Constants.pullPlayerDuration)

        // The pull animation
        let followAnchor = SKAction.customAction(withDuration: duration) { node, _ in
            let newPath = anchorSprite.makePath(to: sprite)
            line.path = newPath

            let dx = anchorSprite.node.position.x - node.position.x
            let dy = anchorSprite.node.position.y - node.position.y
            let angle = atan2(dx, dy)
            if abs(dx) > Constants.speedOfPlayerPull * 5 {
                node.position.x += sin(angle) * Constants.speedOfPlayerPull
            }
            node.position.y += cos(angle) * Constants.speedOfPlayerPull
        }

        sprite.node.run(followAnchor, completion: {
            line.removeFromParent()
            sprite.node.physicsBody?.affectedByGravity = true
            self.delegate?.movement(isDisabled: false, for: sprite)
        })
    }

    // MARK: - Unhook

    /// The player unhooking from a bolt.
    /// - Parameter entity: The player's entity
    func unhook(entity: Entity) -> Bool {
        guard let sprite = entity.get(SpriteComponent.self), let velocity = sprite.node.physicsBody?.velocity else {
            return false
        }

        broadcast(with: sprite, of: .unhook)
        return unhook(entity: entity, at: sprite.node.position, with: velocity)
    }

    /// The player unhooking from a bolt.
    /// - Parameters:
    ///   - entity: The player's entity
    ///   - position: The player's position
    ///   - velocity: The player's velocity
    func unhook(entity: Entity, at position: CGPoint, with velocity: CGVector) -> Bool {
        guard let sprite = entity.get(SpriteComponent.self),
            let hook = entity.get(HookComponent.self)
            else {
            return false
        }

        delegate?.unhookActionApplied(hook: hook)

        sprite.node.position = position
        sprite.node.physicsBody?.velocity = velocity

        hook.prevHookTo = hook.hookTo
        hook.hookTo = nil
        hook.line = nil
        hook.anchorLineJointPin = nil
        hook.parentLineJointPin = nil

        return true
    }

    // MARK: - Adjust length

    /// Adjusting the length of the rope
    /// - Parameters:
    ///   - entity: The player's entity to adjust the rope
    ///   - type: Lengthen or shorten
    func adjustLength(from entity: Entity, type: HookSystemAction) -> Bool {
        guard let sprite = entity.get(SpriteComponent.self), let velocity = sprite.node.physicsBody?.velocity else {
            return false
        }

        var broadcastType = GenericPlayerEvent.shortenRope
        if type == .lengthen {
            broadcastType = .lengthenRope
        }
        broadcast(with: sprite, of: broadcastType)

        return adjustLength(from: entity, type: type, position: sprite.node.position, velocity: velocity)
    }

    private func adjustLength(
        from entity: Entity,
        type: HookSystemAction,
        position: CGPoint,
        velocity: CGVector
    ) -> Bool {
        guard let sprite = entity.get(SpriteComponent.self), let hook = entity.get(HookComponent.self) else {
            return false
        }

        delegate?.unhookActionApplied(hook: hook)

        sprite.node.position = position
        sprite.node.physicsBody?.velocity = velocity

        guard let bolt = hook.hookTo else {
            return false
        }

        adjustRope(sprite: sprite, bolt: bolt, type: type)

        let line = sprite.makeLine(to: bolt)

        // To ensure that the joint pin between bolt-line and player-line should be created
        guard let anchorLineJointPin = makeJointPinToLine(from: bolt.node, toLine: line),
            let spriteLineJointPin = makeJointPinToLine(from: sprite.node, toLine: line)
            else {
                return false
        }

        hook.line = line
        hook.anchorLineJointPin = anchorLineJointPin
        hook.parentLineJointPin = spriteLineJointPin

        delegate?.adjustHookActionApplied(sprite: sprite, velocity: velocity, hook: hook)

        return true
    }

    // MARK: - Rope Checks

    /// Checks if the rope is shorter than a minimum threshold.
    /// - Parameter entity: The player's entity to check
    func isShorterThanMin(for entity: Entity) -> Bool {
        guard let sprite = entity.get(SpriteComponent.self), let hook = entity.get(HookComponent.self) else {
            return false
        }

        guard let bolt = hook.hookTo else {
            return false
        }

        let newPositionVector = Vector(point: sprite.node.position)
        let boltPositionVector = Vector(point: bolt.node.position)
        let ropeLength = newPositionVector.distance(to: boltPositionVector)
        if ropeLength < minRopeLength {
            return true
        }

        return false
    }

    // MARK: - Rope Utility

    private func adjustRope(
        sprite: SpriteComponent,
        bolt: SpriteComponent,
        type: HookSystemAction
    ) {
        let newPosition = getNewSpritePosition(sprite: sprite, bolt: bolt, type: type)

        if type == .lengthen && !isCollidingWithPlatform(sprite: sprite) {
            sprite.node.position = newPosition
        } else if type == .shorten {
            sprite.node.position = newPosition
        }
    }

    private func getNewSpritePosition(
        sprite: SpriteComponent,
        bolt: SpriteComponent,
        type: HookSystemAction
    ) -> CGPoint {
        let (aboveDisplacement, belowDisplacement) = getVerticalBoltDisplacement(
            sprite: sprite,
            bolt: bolt,
            type: type)
        let (rightDisplacement, leftDisplacement) = getHorizontalBoltDisplacement(
            sprite: sprite,
            bolt: bolt,
            type: type)

        var positionYOffset = CGFloat(0)
        var positionXOffset = CGFloat(0)

        let isAboveBolt = sprite.node.position.y > bolt.node.position.y
        let isBelowBolt = sprite.node.position.y < bolt.node.position.y
        let isLeftsideBolt = sprite.node.position.x < bolt.node.position.x
        let isRightsideBolt = sprite.node.position.x > bolt.node.position.x

        if isAboveBolt {
            positionYOffset = CGFloat(aboveDisplacement)
        }

        if isBelowBolt {
            positionYOffset = CGFloat(belowDisplacement)
        }

        if isRightsideBolt {
            positionXOffset = CGFloat(rightDisplacement)
        }

        if isLeftsideBolt {
            positionXOffset = CGFloat(leftDisplacement)
        }
        return CGPoint(
            x: sprite.node.position.x + positionXOffset,
            y: sprite.node.position.y + positionYOffset)
    }

    private func getHorizontalBoltDisplacement(
        sprite: SpriteComponent,
        bolt: SpriteComponent,
        type: HookSystemAction
    ) -> (RightBoltDisplacement, LeftBoltDisplacement) {
        let h = 10.0
        let playerPosVector = Vector(point: sprite.node.position)
        let boltPosVector = Vector(point: bolt.node.position)
        let angle = boltPosVector.angle(from: playerPosVector)
        let x = h * cos(angle)

        var rightBoltDisplacement = -x
        var leftBoltDisplacement = x

        if type == .lengthen {
            rightBoltDisplacement *= -1
            leftBoltDisplacement *= -1
        }

        return (rightBoltDisplacement, leftBoltDisplacement)
    }

    private func getVerticalBoltDisplacement(
        sprite: SpriteComponent,
        bolt: SpriteComponent,
        type: HookSystemAction
    ) -> (AboveBoltDisplacement, BelowBoltDisplacement) {
        let h = 10.0
        let playerPosVector = Vector(point: sprite.node.position)
        let boltPosVector = Vector(point: bolt.node.position)
        let angle = boltPosVector.angle(from: playerPosVector)
        let y = h * sin(angle)

        var aboveBoltDisplacement = -y
        var belowBoltDisplacement = y

        if type == .lengthen {
            aboveBoltDisplacement *= -1
            belowBoltDisplacement *= -1
        }

        return (aboveBoltDisplacement, belowBoltDisplacement)
    }

    /// Checks if the sprite is colliding with any platform
    /// - Parameter sprite: The sprite to check
    private func isCollidingWithPlatform(sprite: SpriteComponent) -> Bool {
        guard let physicsBody = sprite.node.physicsBody else {
            return false
        }
        let contactedPhysicsBodies = physicsBody.allContactedBodies()
        for contactedBody in contactedPhysicsBodies {
            guard let spriteNode = contactedBody.node as? SKSpriteNode else {
                return false
            }
            if spriteNode.name == GameObjectType.platform.rawValue
                || spriteNode.name == GameObjectType.platformMovable.rawValue {
                return true
            }
        }

        return false
    }

    // MARK: - Add Initial Velocity

    /// Apply initial velocity back to the sprite.
    /// - Parameters:
    ///   - sprite: The sprite to apply on
    ///   - velocity: The velocity to apply back
    func applyInitialVelocity(sprite: SpriteComponent, velocity: CGVector) {
        sprite.node.physicsBody?.applyImpulse(velocity)
    }

    // MARK: - Booster

    /// Boost the entity velocity.
    /// - Parameter entity: The entity to boost
    func boostVelocity(to entity: Entity) {
        guard let hook = entity.get(HookComponent.self) else {
            return
        }

        let isAttachingToSameBolt = hook.hookTo == hook.prevHookTo

        if !isAttachingToSameBolt {
            guard let sprite = entity.get(SpriteComponent.self), let bolt = hook.hookTo else {
                return
            }

            var boostX = 1_000
            let boostY = -1_000

            let isInFrontOfBolt = sprite.node.position.x > bolt.node.position.x

            if isInFrontOfBolt {
                boostX *= -1
            }

            let boost = CGVector(dx: boostX, dy: boostY)
            sprite.node.physicsBody?.applyImpulse(boost)
        }
    }

    // MARK: - Find Closest Bolt

    private func findClosestBolt(from position: CGPoint) -> SpriteComponent? {
        var closestBolt: SpriteComponent?
        var closestDistance = Double.greatestFiniteMagnitude
        let positionVector = Vector(point: position)
        for bolt in bolts {
            let boltVectorPosition = Vector(point: bolt.node.position)
            let distance = positionVector.distance(to: boltVectorPosition)
            closestDistance = min(Double(distance), closestDistance)
            if closestDistance == Double(distance) {
                closestBolt = bolt
            }
        }

        return closestBolt
    }

    // MARK: - Create Joint

    /// Make a joint pin to the line.
    /// - Parameters:
    ///   - node: The node to join the line to
    ///   - line: The line
    private func makeJointPinToLine(from node: SKNode, toLine line: SKShapeNode) -> SKPhysicsJointPin? {
        guard let nodePhysicsBody = node.physicsBody, let linePhysicsBody = line.physicsBody else {
            return nil
        }

        let jointPin = SKPhysicsJointPin.joint(
            withBodyA: nodePhysicsBody,
            bodyB: linePhysicsBody,
            anchor: node.position
        )

        return jointPin
    }
}

// MARK: - Networking

extension HookSystem {
    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedHookAction(_:)),
            name: .receivedHookAction,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedUnhookAction(_:)),
            name: .receivedUnhookAction,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedShortenRopeAction(_:)),
            name: .receivedShortenRopeAction,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedLengthenRopeAction(_:)),
            name: .receivedLengthenRopeAction,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(broadcastUnregisterObserver(_:)),
            name: .broadcastUnregisterObserver,
            object: nil)
    }

    /// Broadcast to the Notification Center
    private func broadcast(with sprite: SpriteComponent, of eventType: GenericPlayerEvent) {
        let genericSystemEvent = GenericSystemEvent(sprite: sprite, eventType: eventType)
        NotificationCenter.default.post(
            name: .broadcastGenericPlayerAction,
            object: self,
            userInfo: ["data": genericSystemEvent])
    }

    @objc private func receivedHookAction(_ notification: Notification) {
        if let data = notification.userInfo as? [String: GenericSystemEvent] {
            guard let genericSystemEvent = data["data"] else {
                return
            }

            let sprite = genericSystemEvent.sprite
            guard let velocity = sprite.node.physicsBody?.velocity else {
                return
            }

            _ = hook(from: sprite.parent, at: sprite.node.position, with: velocity)
        }
    }

    @objc private func receivedUnhookAction(_ notification: Notification) {
        if let data = notification.userInfo as? [String: GenericSystemEvent] {
            guard let genericSystemEvent = data["data"] else {
                return
            }

            let sprite = genericSystemEvent.sprite
            guard let velocity = sprite.node.physicsBody?.velocity else {
                return
            }

            _ = unhook(entity: sprite.parent, at: sprite.node.position, with: velocity)
        }
    }

    @objc private func receivedShortenRopeAction(_ notification: Notification) {
        if let data = notification.userInfo as? [String: GenericSystemEvent] {
            guard let genericSystemEvent = data["data"] else {
                return
            }

            let sprite = genericSystemEvent.sprite
            guard let velocity = sprite.node.physicsBody?.velocity else {
                return
            }

            _ = adjustLength(from: sprite.parent, type: .shorten, position: sprite.node.position, velocity: velocity)
        }
    }

    @objc private func receivedLengthenRopeAction(_ notification: Notification) {
        if let data = notification.userInfo as? [String: GenericSystemEvent] {
            guard let genericSystemEvent = data["data"] else {
                return
            }

            let sprite = genericSystemEvent.sprite
            guard let velocity = sprite.node.physicsBody?.velocity else {
                return
            }

            _ = adjustLength(from: sprite.parent, type: .lengthen, position: sprite.node.position, velocity: velocity)
        }
    }

    @objc private func broadcastUnregisterObserver(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
    }
}
