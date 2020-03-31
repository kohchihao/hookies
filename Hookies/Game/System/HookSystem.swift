//
//  HookSystem.swift
//  Hookies
//
//  Created by JinYing on 28/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

/// Represent entity that will be potentially hooked to another entity

protocol HookSystemProtocol {
    func add(hook: HookComponent) -> HookComponent
    func hookTo(hook: HookComponent) throws
    func unhookFrom(entity: Entity) throws
}

enum HookSystemError: Error {
    case hookComponentDoesNotExist
    case spriteComponentDoesNotExist
    case closestHookToEntityDoesNotExist
    case physicsBodyDoesNotExist
}

class HookSystem: System, HookSystemProtocol {
    private var hooks: Set<HookComponent>
    private var bolts: [SpriteComponent]

    init(bolts: [SpriteComponent]) {
        self.hooks = Set<HookComponent>()
        self.bolts = bolts
    }

    func add(hook: HookComponent) -> HookComponent {
        let (_, element) = hooks.insert(hook)

        return element
    }

    func hookTo(hook: HookComponent) throws {
        guard let systemHook = hooks.first(where: { $0 == hook }) else {
            throw HookSystemError.hookComponentDoesNotExist
        }

        guard let parentSprite = getParentSprite(of: systemHook) else {
            throw HookSystemError.spriteComponentDoesNotExist
        }

        guard let closestBolt = findClosestBolt(from: parentSprite.node.position) else {
            throw HookSystemError.closestHookToEntityDoesNotExist
        }

        let isAttachingToSameBolt = hook.prevHookTo?.node.position == closestBolt.node.position
        if isAttachingToSameBolt {
            attachToSameBolt(sprite: parentSprite, bolt: closestBolt)
        }

        let anchor = parentSprite.makeAnchor(from: closestBolt)
        let line = parentSprite.makeLine(to: closestBolt)

        guard let anchorLineJointPin = makeJointPinToLine(from: anchor, toLine: line),
            let spriteLineJointPin = makeJointPinToLine(from: parentSprite.node, toLine: line) else {
                throw HookSystemError.physicsBodyDoesNotExist
        }

        systemHook.hookTo = closestBolt
        systemHook.anchor = anchor
        systemHook.line = line
        systemHook.anchorLineJointPin = anchorLineJointPin
        systemHook.parentLineJointPin = spriteLineJointPin
    }

    func unhookFrom(entity: Entity) throws {
        guard let hook = getHook(from: entity) else {
            throw HookSystemError.hookComponentDoesNotExist
        }

        hook.prevHookTo = hook.hookTo
        hook.hookTo = nil
        hook.anchor = nil
        hook.line = nil
        hook.anchorLineJointPin = nil
        hook.parentLineJointPin = nil
    }

    private func getParentSprite(of hook: HookComponent) -> SpriteComponent? {
        return getSprite(from: hook.parent)
    }

    private func getSprite(from entity: Entity) -> SpriteComponent? {
        for component in entity.components {
            if let sprite = component as? SpriteComponent {
                return sprite
            }
        }

        return nil
    }

    private func getHook(from entity: Entity) -> HookComponent? {
        for component in entity.components {
            if let hook = component as? HookComponent {
                return hook
            }
        }

        return nil
    }

    private func findClosestBolt(from position: CGPoint) -> SpriteComponent? {
        var closestBolt: SpriteComponent?
        var closestDistance = Double.greatestFiniteMagnitude

        for bolt in bolts {
            let boltPosition = bolt.node.position
            let distance = position.distance(to: boltPosition)
            closestDistance = min(Double(distance), closestDistance)
            if closestDistance == Double(distance) {
                closestBolt = bolt
            }
        }

        return closestBolt
    }

    private func makeJointPinToLine(from node: SKNode, toLine line: SKShapeNode) -> SKPhysicsJointPin? {
        guard let nodePhysicsBody = node.physicsBody,
            let linePhysicsBody = line.physicsBody
            else {
                return nil
        }

        let jointPin = SKPhysicsJointPin.joint(
            withBodyA: nodePhysicsBody,
            bodyB: linePhysicsBody,
            anchor: node.position
        )

        return jointPin
    }

    private func attachToSameBolt(sprite: SpriteComponent, bolt: SpriteComponent) {
        var positionYOffset = CGFloat(0)

        let isAboveBolt = sprite.node.position.y > bolt.node.position.y
        let isBelowBolt = sprite.node.position.y < bolt.node.position.y

        if isAboveBolt {
            positionYOffset = CGFloat(-15)
        }

        if isBelowBolt {
            positionYOffset = CGFloat(15)
        }

        sprite.node.position = CGPoint(x: sprite.node.position.x, y: sprite.node.position.y + positionYOffset)
    }
}

// MARK: - Broadcast Update

extension HookSystem {
    func broadcastUpdate(gameId: String, playerId: String, player: PlayerEntity, type: HookActionType) {
        guard let hookActionData = createHookAction(from: playerId, and: player, of: type) else {
            return
        }

        API.shared.gameplay.broadcastHookAction(hookAction: hookActionData)
    }

    private func createHookAction(
        from playerId: String,
        and player: PlayerEntity,
        of type: HookActionType
    ) -> HookActionData? {
        guard let sprite = getSprite(from: player) else {
            return nil
        }

        let hookActionData = HookActionData(
            playerId: playerId,
            position: sprite.node.position,
            velocity: sprite.node.physicsBody?.velocity,
            type: type
        )

        return hookActionData
    }
}
