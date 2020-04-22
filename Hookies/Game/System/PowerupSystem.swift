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
    func add(player: SpriteComponent)
    func add(powerup: PowerupComponent)
    func removePowerup(from player: SpriteComponent)
    func collectAndBroadcast(powerupComponent: PowerupComponent,
                             by sprite: SpriteComponent)
    func activateNetTrapAndBroadcast(at point: CGPoint,
                                     on sprite: SpriteComponent)
}

protocol PowerupSystemDelegate: class, MovementControlDelegate {
    func hasAddedTrap(sprite: SpriteComponent)
    func collected(powerup: PowerupComponent, by sprite: SpriteComponent)
    func hook(_ sprite: SpriteComponent, from anchorSprite: SpriteComponent)
    func forceUnhookFor(player: SpriteComponent)
    func indicateSteal(from sprite: SpriteComponent,
                       by sprite: SpriteComponent,
                       with powerup: PowerupComponent)
}

class PowerupSystem: System, PowerupSystemProtocol {
    weak var delegate: PowerupSystemDelegate?

    // Key: sprite of player, Value: powerup of player
    private var ownedPowerups = [SpriteComponent: [PowerupComponent]]()
    // Powerups that are collectible on the map
    private var powerups = Set<PowerupComponent>()
    private var netTraps = Set<SpriteComponent>()

    var players: [SpriteComponent] {
        return Array(ownedPowerups.keys)
    }

    init() {
        registerNotificationObservers()
    }

    // MARK: Add Player
    func add(player: SpriteComponent) {
        ownedPowerups[player] = []
    }

    // MARK: Add Powerup
    func add(powerup: PowerupComponent) {
        powerups.insert(powerup)
    }

    // MARK: Remove Powerup
    func removePowerup(from player: SpriteComponent) {
        guard let removedPowerup = ownedPowerups[player]?.removeFirst() else {
            return
        }
        player.parent.removeFirstComponent(of: removedPowerup)
    }

    // MARK: - Collect Powerup
    func collectAndBroadcast(powerupComponent: PowerupComponent,
                             by sprite: SpriteComponent
    ) {
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

    // MARK: - Activate Powerup
    func activateAndBroadcast(powerupType: PowerupType,
                              for sprite: SpriteComponent
    ) {
        activate(powerupType: powerupType, by: sprite)
        let info = [
            "data": PowerupSystemEvent(sprite: sprite,
                                       powerupEventType: .activate,
                                       powerupType: powerupType)
        ]
        NotificationCenter.default.post(name: Notification.Name.broadcastPowerupAction,
                                        object: nil,
                                        userInfo: info)
    }

    func activateNetTrapAndBroadcast(at point: CGPoint,
                                     on sprite: SpriteComponent) {
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

    // MARK: - Steal Powerup

    private func steal(from player1: SpriteComponent,
                       by player2: SpriteComponent
    ) {
        guard let powerupToSteal = ownedPowerups[player1]?.first else {
            Logger.log.show(details: "No powerup to steal", logType: .warning)
            return
        }
        Logger.log.show(details: "Power up stolen \(powerupToSteal.type.stringValue)",
                        logType: .alert)

        removePowerup(from: player1)
        add(player: player2, with: powerupToSteal)
        delegate?.indicateSteal(from: player1, by: player2, with: powerupToSteal)
    }

    // MARK: Add player's Powerup

    private func add(player: SpriteComponent, with powerup: PowerupComponent) {
        ownedPowerups[player]?.removeAll()
        ownedPowerups[player]?.append(powerup)
        player.parent.addComponent(powerup)
        powerup.setOwner(player.parent)
    }

    // MARK: - Activate Net Trap

    private func activateNetTrap(at point: CGPoint, on sprite: SpriteComponent) {
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
            apply(effect: effect, on: sprite)
        }
    }

    // MARK: - Activate Powerup

    private func activate(powerupType: PowerupType,
                          by sprite: SpriteComponent
    ) {
        guard let powerup = ownedPowerups[sprite]?.first else {
            return
        }

        powerup.type = powerupType
        powerup.isActivated = true
        powerup.addEffectComponents(for: powerupType)
        let effects = powerup.parent.getMultiple(PowerupEffectComponent.self)
        for effect in effects {
            apply(effect: effect, on: sprite)
        }
    }

    private func apply(effect: PowerupEffectComponent,
                       on sprite: SpriteComponent) {
        if isProtected(spriteComponent: sprite, from: effect) {
            return
        }

        switch effect {
        case let shield as ShieldEffectComponent:
            applyShieldEffect(shield, on: sprite)
        case let movementEffect as MovementEffectComponent:
            applyMovementEffect(movementEffect, on: sprite)
        case let placementEffect as PlacementEffectComponent:
            applyPlacementEffect(placementEffect, by: sprite)
        case let playerHookEffect as PlayerHookEffectComponent:
            applyPlayerHookEffect(playerHookEffect, by: sprite)
        case let cutRopeEffect as CutRopeEffectComponent:
            applyCutRopeEffect(cutRopeEffect, by: sprite)
        case let stealEffect as StealPowerupEffectComponent:
            applyStealPowerupEffect(stealEffect, by: sprite)
        default:
            return
        }
    }

    // MARK: - Collect Powerup

    private func collect(powerupComponent: PowerupComponent,
                         by sprite: SpriteComponent
    ) {
        guard let powerupSprite = powerupComponent.parent.get(SpriteComponent.self)
            else {
                return
        }
        powerups.remove(powerupComponent)
        powerupComponent.parent.removeComponents(SpriteComponent.self)
        add(player: sprite, with: powerupComponent)

        let fade = SKAction.fadeOut(withDuration: 0.5)
        powerupSprite.node.run(fade, completion: {
            powerupSprite.node.removeFromParent()
        })
    }

    // MARK: - Find Trap

    private func findTrap(at point: CGPoint) -> SpriteComponent? {
        for trap in netTraps where trap.node.frame.contains(point) {
            return trap
        }
        return nil
    }

    // MARK: - isProtected

    private func isProtected(spriteComponent: SpriteComponent,
                             from effect: PowerupEffectComponent
    ) -> Bool {
        guard let powerup = ownedPowerups[spriteComponent]?.first else {
            return false
        }
        let hasShieldEffect = powerup.parent.get(ShieldEffectComponent.self) != nil
        return effect.isNegativeEffect && powerup.isActivated && hasShieldEffect
    }

    // MARK: - Apply Effects

    private func applyStealPowerupEffect(_ effect: StealPowerupEffectComponent,
                                         by sprite: SpriteComponent) {
        guard let nearestSprite = sprite.nearestSpriteInFront(from: players) else {
            Logger.log.show(details: "No players in front to steal powerup",
                            logType: .warning)
            return
        }
        guard !isProtected(spriteComponent: nearestSprite, from: effect) else {
            Logger.log.show(details: "Cannot steal from shielded player.",
                            logType: .warning)
            return
        }
        steal(from: nearestSprite, by: sprite)
        effect.parent.removeComponents(StealPowerupEffectComponent.self)
    }

    private func applyCutRopeEffect(_ effect: CutRopeEffectComponent,
                                    by sprite: SpriteComponent) {
        let players = Array(ownedPowerups.keys).filter({
            $0 !== sprite && !isProtected(spriteComponent: $0, from: effect)
        })

        for player in players {
            delegate?.forceUnhookFor(player: player)
        }
        effect.parent.removeComponents(CutRopeEffectComponent.self)
        removePowerup(from: sprite)
    }

    private func applyPlayerHookEffect(_ effect: PlayerHookEffectComponent,
                                       by sprite: SpriteComponent) {
        guard let nearestSprite = sprite.nearestSpriteInFront(from: players) else {
            Logger.log.show(details: "No players to hook in front.", logType: .warning)
            return
        }
        guard !isProtected(spriteComponent: nearestSprite, from: effect) else {
            Logger.log.show(details: "Cannot hook onto shielded player",
                            logType: .warning)
            return
        }

        delegate?.hook(nearestSprite, from: sprite)
        removePowerup(from: sprite)
        effect.parent.removeComponents(PlayerHookEffectComponent.self)
    }

    private func applyPlacementEffect(_ effect: PlacementEffectComponent,
                                      by sprite: SpriteComponent) {
        guard let effectSprite = effect.parent.get(SpriteComponent.self),
            let powerupCom = effect.parent.get(PowerupComponent.self) else {
            return
        }
        switch powerupCom.type {
        case .netTrap:
            let movementComponent = MovementEffectComponent(parent: effect.parent,
                                                            isNegativeEffect: true)
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
        removePowerup(from: sprite)
        effect.parent.removeComponents(PlacementEffectComponent.self)
    }

    private func applyMovementEffect(_ effect: MovementEffectComponent,
                                     on sprite: SpriteComponent) {
        guard let initialPoint = effect.from,
            let endPoint = effect.to,
            let duration = effect.duration else {
                return
        }

        delegate?.movement(isDisabled: true, for: sprite)
        if effect.stopMovement {
            sprite.node.physicsBody?.affectedByGravity = false
        }
        sprite.node.position = initialPoint
        let action = SKAction.move(to: endPoint, duration: duration)
        sprite.node.run(action, completion: {
            sprite.node.physicsBody?.affectedByGravity = true
            effect.parent.get(SpriteComponent.self)?.node.removeFromParent()
            effect.parent.removeComponents(MovementEffectComponent.self)
            self.delegate?.movement(isDisabled: false, for: sprite)
        })
    }

    private func applyShieldEffect(_ effect: ShieldEffectComponent,
                                   on sprite: SpriteComponent) {
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
            self.removePowerup(from: sprite)
        }
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(broadcastUnregisterObserver(_:)),
            name: .broadcastUnregisterObserver,
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

        powerup.type = collectionEvent.powerupType
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
            activate(powerupType: powerupEvent.powerupType, by: playerSprite)
        case .netTrapped:
            let eventPos = CGPoint(vector: powerupEvent.powerupPos)
            activateNetTrap(at: eventPos, on: playerSprite)
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

    @objc private func broadcastUnregisterObserver(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
    }
}
