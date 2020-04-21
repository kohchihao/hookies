//
//  PowerupSystem.swift
//  Hookies
//
//  Created by Jun Wei Koh on 30/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics
import SpriteKit

protocol PowerupSystemProtocol {
}

protocol PowerupSystemDelegate: class {
    func hasAddedTrap(sprite: SpriteComponent)
    func collected(powerup: PowerupComponent, by sprite: SpriteComponent)
}

class PowerupSystem: System, PowerupSystemProtocol {
    weak var delegate: PowerupSystemDelegate?

    // Key: sprite of player, Value: powerup of player
    private var ownedPowerups = [SpriteComponent: PowerupComponent]()
    // Powerups that are collectible on the map
    private var powerups = Set<PowerupComponent>()
    private var netTraps = Set<SpriteComponent>()

    init() {
        registerNotificationObservers()
    }

    func add(powerup: PowerupComponent) {
        powerups.insert(powerup)
    }

    func remove(powerup: PowerupComponent, from player: SpriteComponent) {
        guard let powerupIndex = ownedPowerups.index(forKey: player) else {
                return
        }

        ownedPowerups.remove(at: powerupIndex)
        player.parent.removeFirstComponent(of: powerup)
    }

    func collectAndBroadcast(powerupComponent: PowerupComponent, by sprite: SpriteComponent) {
        guard let powerupSprite = powerupComponent.parent.get(SpriteComponent.self) else {
            return
        }

        collect(powerupComponent: powerupComponent, by: sprite)
        let powerupPos = Vector(point: powerupSprite.node.position)
        let info = [
            "data": PowerupCollectionSystemEvent(sprite: sprite,
                                                 powerupPos: powerupPos,
                                                 powerupType: powerupComponent.type)
        ]
        NotificationCenter.default.post(name: Notification.Name.broadcastPowerupCollectionEvent,
                                        object: nil,
                                        userInfo: info)
    }

    func activateAndBroadcast(powerupType: PowerupType,
                              for sprite: SpriteComponent
    ) {
        activate(powerupType: powerupType, for: sprite)
        let info = [
            "data": PowerupSystemEvent(sprite: sprite,
                                       powerupEventType: .activate,
                                       powerupType: powerupType)
        ]
        NotificationCenter.default.post(name: Notification.Name.broadcastPowerupAction,
                                        object: nil,
                                        userInfo: info)
    }

    func deactivate(powerup: PowerupComponent, for sprite: SpriteComponent) {
        guard let powerupIndex = ownedPowerups.index(forKey: sprite) else {
                return
        }

        let playerPowerups = sprite.parent.getMultiple(PowerupComponent.self)
        if let indexToRemove = playerPowerups.firstIndex(of: powerup) {
            ownedPowerups.remove(at: powerupIndex)
            sprite.parent.components.remove(at: indexToRemove)
        }
    }

    func steal(powerup: PowerupComponent,
               from player1: SpriteComponent,
               by player2: SpriteComponent
    ) {
        guard let powerupToSteal = player1.parent.get(PowerupComponent.self) else {
                return
        }

        remove(powerup: powerupToSteal, from: player1)
        add(player: player2, with: powerupToSteal)
    }

    func apply(effect: PowerupEffectComponent,
               by sprite: SpriteComponent) {
        if !(effect is ShieldEffectComponent) && isProtected(spriteComponent: sprite) {
            return
        }

        switch effect {
        case let shield as ShieldEffectComponent:
            applyShieldEffect(shield, by: sprite)
        case let placementEffect as PlacementEffectComponent:
            applyPlacementEffect(placementEffect, by: sprite)
        case let movementEffect as MovementEffectComponent:
            applyMovementEffect(movementEffect, by: sprite)
        default:
            return
        }
    }

    func activateNetTrapAndBroadcast(at point: CGPoint, on sprite: SpriteComponent) {
        guard let trap = findTrap(at: point) else {
            Logger.log.show(details: "Unable find netTrap", logType: .error)
            return
        }

        activateNetTrap(at: point, on: sprite)
        let info = [
            "data": PowerupSystemEvent(sprite: sprite,
                                       powerupEventType: .netTrapped,
                                       powerupType: .netTrap,
                                       powerupPos: Vector(point: trap.node.position))
        ]
        NotificationCenter.default.post(name: Notification.Name.broadcastPowerupAction,
                                        object: nil,
                                        userInfo: info)
    }

    func activateNetTrap(at point: CGPoint, on sprite: SpriteComponent) {
        guard let trap = findTrap(at: point),
            let owner = trap.parent.get(PowerupComponent.self)?.owner
            else {
                Logger.log.show(details: "Unable find netTrap", logType: .error)
                return
        }

        if sprite.parent === owner {
            return
        }

        let effects = trap.parent.getMultiple(PowerupEffectComponent.self)
        for effect in effects {
            apply(effect: effect, by: sprite)
        }
    }

    private func add(player: SpriteComponent, with powerup: PowerupComponent) {
        ownedPowerups[player] = powerup
        player.parent.addComponent(powerup)
    }

    private func activate(powerupType: PowerupType,
                          for sprite: SpriteComponent
    ) {
        guard let powerup = ownedPowerups[sprite] else {
            return
        }

        powerup.type = powerupType
        powerup.isActivated = true
        powerup.addEffectComponents(for: powerupType)
        let effects = powerup.parent.getMultiple(PowerupEffectComponent.self)
        for effect in effects {
            apply(effect: effect, by: sprite)
        }
    }

    private func collect(powerupComponent: PowerupComponent, by sprite: SpriteComponent) {
        guard let powerupSprite = powerupComponent.parent.get(SpriteComponent.self)
            else {
                return
        }
        powerups.remove(powerupComponent)
        add(player: sprite, with: powerupComponent)
        powerupComponent.parent.removeComponents(SpriteComponent.self)

        let fade = SKAction.fadeOut(withDuration: 0.5)
        powerupSprite.node.run(fade, completion: {
            powerupSprite.node.removeFromParent()
        })
        powerupComponent.setOwner(sprite.parent)
    }

    private func findTrap(at point: CGPoint) -> SpriteComponent? {
        for trap in netTraps where trap.node.frame.contains(point) {
            return trap
        }
        return nil
    }

    private func applyPlacementEffect(_ effect: PlacementEffectComponent,
                                      by sprite: SpriteComponent) {
        guard let effectSprite = effect.parent.get(SpriteComponent.self),
            let powerupCom = effect.parent.get(PowerupComponent.self) else {
            return
        }
        switch powerupCom.type {
        case .netTrap:
            let movementComponent = MovementEffectComponent(parent: effect.parent)
            movementComponent.duration = 5.0
            movementComponent.from = sprite.node.position
            movementComponent.to = sprite.node.position
            movementComponent.stopMovement = true
            effect.parent.addComponent(movementComponent)
            effectSprite.node.position = sprite.node.position
            netTraps.insert(effectSprite)
            delegate?.hasAddedTrap(sprite: effectSprite)
        default:
            return
        }
        effect.parent.removeComponents(PlacementEffectComponent.self)
    }

    private func applyMovementEffect(_ effect: MovementEffectComponent,
                                     by sprite: SpriteComponent) {
        guard let initialPoint = effect.from,
            let endPoint = effect.to,
            let duration = effect.duration,
            let effectSprite = effect.parent.get(SpriteComponent.self) else {
                return
        }

        if effect.stopMovement {
            sprite.node.physicsBody?.affectedByGravity = false
        }
        sprite.node.position = initialPoint
        let action = SKAction.move(to: endPoint, duration: duration)
        sprite.node.run(action, completion: {
            sprite.node.physicsBody?.affectedByGravity = true
            effectSprite.node.removeFromParent()
            effect.parent.removeComponents(MovementEffectComponent.self)
        })
    }

    private func applyShieldEffect(_ effect: ShieldEffectComponent,
                                   by sprite: SpriteComponent) {
        let shieldTexture = SKTexture(imageNamed: "shield_bubble")
        let shieldSize = CGSize(width: sprite.node.size.width * 2,
                                height: sprite.node.size.height * 2)
        let shieldNode = SKSpriteNode(texture: shieldTexture,
                                      color: .clear,
                                      size: shieldSize)
        sprite.node.addChild(shieldNode)
        DispatchQueue.main.asyncAfter(deadline: .now() + effect.duration) {
            effect.parent.removeComponents(ShieldEffectComponent.self)
            shieldNode.removeFromParent()
        }
    }

    private func isProtected(spriteComponent: SpriteComponent) -> Bool {
        guard let powerup = ownedPowerups[spriteComponent] else {
            return false
        }
        let hasShieldEffect = powerup.parent.get(ShieldEffectComponent.self) != nil
        return powerup.isActivated && hasShieldEffect
    }
}

// MARK: - Networking

extension PowerupSystem {
    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedPowerupCollectionAction(_:)),
            name: .receviedPowerupCollectionEvent,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedPowerupEventAction(_:)),
            name: .receivedPowerupAction,
            object: nil)
    }

    @objc private func receivedPowerupCollectionAction(_ notification: Notification) {
        guard let data = notification.userInfo as? [String: PowerupCollectionSystemEvent],
            let collectionEvent = data["data"] else {
                return
        }
        let positionOfCollection = CGPoint(vector: collectionEvent.powerupPos)

        guard let powerup = findPowerup(at: positionOfCollection),
            let sprite = collectionEvent.sprite.parent.get(SpriteComponent.self)
            else {
                return
        }

        powerups.remove(powerup)
        collect(powerupComponent: powerup, by: sprite)
        delegate?.collected(powerup: powerup, by: sprite)
    }

    @objc private func receivedPowerupEventAction(_ notification: Notification) {
        guard let data = notification.userInfo as? [String: PowerupSystemEvent],
            let powerupEvent = data["data"] else {
                return
        }

        let playerSprite = powerupEvent.sprite
        switch powerupEvent.powerupEventType {
        case .activate:
            activate(powerupType: powerupEvent.powerupType, for: playerSprite)
        case .netTrapped:
            let eventPos = CGPoint(vector: powerupEvent.powerupPos)
            activateNetTrap(at: eventPos, on: playerSprite)
        case.deactivate:
            return
        }
    }

    private func findPowerup(at point: CGPoint) -> PowerupComponent? {
        for powerup in powerups {
            guard let sprite = powerup.parent.get(SpriteComponent.self) else {
                continue
            }
            if sprite.node.frame.contains(point) {
                return powerup
            }
        }
        return nil
    }
}
