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

protocol PowerupSystemDelegate: MovementControlDelegate {

    /// Indicates that the trap has been added.
    /// - Parameter sprite: The trap's sprite
    func hasAddedTrap(sprite: SpriteComponent)

    /// Indicates that the power up has been collected
    /// - Parameters:
    ///   - powerup: The power up collected
    ///   - sprite: The sprite that colelcted the power up
    func collected(powerup: PowerupComponent, by sprite: SpriteComponent)

    /// Hooking power up applied.
    /// - Parameters:
    ///   - sprite: The sprite that applied the power up
    ///   - anchorSprite: The sprite that was affected by the power up
    func hook(_ sprite: SpriteComponent, from anchorSprite: SpriteComponent)

    /// Unhook the sprite.
    /// - Parameter player: The sprite to unhook
    func forceUnhookFor(player: SpriteComponent)

    /// Indicates that steal has occurred.
    /// - Parameters:
    ///   - sprite: The sprite that was stolen from
    ///   - sprite: The sprite that stole
    ///   - powerup: The power up stolen
    func indicateSteal(from sprite: SpriteComponent,
                       by sprite: SpriteComponent,
                       with powerup: PowerupComponent)
}

class PowerupSystem: System, PowerupSystemProtocol {
    weak var delegate: PowerupSystemDelegate?

    // Key: sprite of player, Value: powerups of player
    private var ownedPowerups = [SpriteComponent: [PowerupComponent]]()
    // Key: sprite of player, Value: activated powerups of player
    private var activatedPowerups = [SpriteComponent: [PowerupComponent]]()

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

    /// Will add the player to the system.
    /// - Parameter player: The sprite component of the player.
    func add(player: SpriteComponent) {
        ownedPowerups[player] = []
        activatedPowerups[player] = []
    }

    // MARK: Remove/Add Powerup

    /// Will add the powerup component into the system
    /// - Parameter powerup: The powerup component to add into the system.
    func add(powerup: PowerupComponent) {
        powerups.insert(powerup)
    }

    /// Will remove the powerup owned by the  player.
    /// - Parameter player: The player which you want the power up to be removed.
    func removePowerup(from player: SpriteComponent) {
        guard let powerupToRemove = powerup(for: player),
            let indexToRemove = ownedPowerups[player]?.firstIndex(of: powerupToRemove) else {
            return
        }
        ownedPowerups[player]?.remove(at: indexToRemove)
        player.parent.removeFirstComponent(of: powerupToRemove)
    }

    /// Will add the activated powerup into the activated power up array.
    /// If not activated, do nothing.
    /// - Parameters:
    ///   - powerup: The activated powerup component
    ///   - sprite: The sprite that owns the powerup
    private func addActivated(powerup: PowerupComponent, to sprite: SpriteComponent) {
        if powerup.isActivated {
            activatedPowerups[sprite]?.append(powerup)
        }
    }

    /// Will remove the activated powerup from the system. To use then when the powerup has be used.
    /// - Parameters:
    ///   - powerup: The activated powerup component to remove.
    ///   - sprite: The sprite that owns the powerup.
    private func removeActivated(powerup: PowerupComponent, from sprite: SpriteComponent) {
        activatedPowerups[sprite]?.removeAll(where: { $0 === powerup })
    }

    // MARK: - Collect Powerup

    /// Will trigger the sprite to collect the given powerup.
    /// Will also broadcast this event to other players.
    /// - Parameters:
    ///   - powerupComponent: The powerup component to be collected
    ///   - sprite: The sprite that collects the powerup.
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

    /// Will activate the powerup that is owned by the sprite.
    /// Will also broadcast this event to other players.
    /// - Parameters:
    ///   - powerupType: The powerup type to be activated.
    ///   - sprite: the sprite that triggers this activation.
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

    /// Will activate the netTrap event that is activated on the given sprite.
    /// Will also broadcast this event to other players.
    /// - Parameters:
    ///   - point: The point at which this activate occurs.
    ///   - sprite: The sprite that gets trap in the net
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

    // MARK: - Get player's powerup
    private func powerup(for sprite: SpriteComponent) -> PowerupComponent? {
        return ownedPowerups[sprite]?.first
    }

    // MARK: - Steal Powerup

    private func steal(from player1: SpriteComponent,
                       by player2: SpriteComponent
    ) {
        guard let powerupToSteal = powerup(for: player1) else {
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
        removePowerup(from: player)
        ownedPowerups[player]?.append(powerup)
        powerup.setOwner(player.parent)
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

    /// Will find a trap at the given point if any.
    private func findTrap(at point: CGPoint) -> SpriteComponent? {
        for trap in netTraps where trap.node.frame.contains(point) {
            return trap
        }
        return nil
    }

    // MARK: - isProtected

    /// Determine whether the sprite is protected from the given effect
    private func isProtected(spriteComponent: SpriteComponent,
                             from effect: PowerupEffectComponent
    ) -> Bool {
        guard let shieldPowerup = activatedPowerups[spriteComponent]?
            .first(where: { $0.type == .shield }) else {
                return false
        }
        let hasShieldEffect = shieldPowerup.parent.get(ShieldEffectComponent.self) != nil
        return effect.isNegativeEffect && shieldPowerup.isActivated && hasShieldEffect
    }

    // MARK: - Activate Net Trap

    private func activateNetTrap(at point: CGPoint, on sprite: SpriteComponent) {
        guard let trap = findTrap(at: point),
            let powerup = trap.parent.get(PowerupComponent.self),
            let owner = powerup.owner
            else {
                Logger.log.show(details: "Unable find netTrap", logType: .error)
                return
        }

        if sprite.parent === owner {
            return
        }
        apply(powerup: powerup, on: sprite)
    }

    // MARK: - Activate Powerup

    /// Will activate the powerup type which is triggered by the given sprite.
    private func activate(powerupType: PowerupType,
                          by sprite: SpriteComponent
    ) {
        guard let powerup = powerup(for: sprite) else {
            return
        }

        powerup.type = powerupType
        powerup.isActivated = true
        powerup.addEffectComponents(for: powerupType)
        removePowerup(from: sprite)
        addActivated(powerup: powerup, to: sprite)
        apply(powerup: powerup, on: sprite)
    }

    /// Will apply the powerup on the sprite.
    private func apply(powerup: PowerupComponent, on sprite: SpriteComponent) {
        let effects = powerup.parent.getMultiple(PowerupEffectComponent.self)
        for effect in effects {
            apply(effect: effect, on: sprite) {
                Logger.log.show(details: "Completed powerup", logType: .alert)
                effect.parent.removeFirstComponent(of: effect)
                self.removeActivated(powerup: powerup, from: sprite)
            }
        }
    }

    /// Will apply the effect on the sprite
    private func apply(effect: PowerupEffectComponent,
                       on sprite: SpriteComponent,
                       complete: @escaping () -> Void
    ) {
        if isProtected(spriteComponent: sprite, from: effect) {
            return
        }

        switch effect {
        case let shield as ShieldEffectComponent:
            applyShieldEffect(shield, on: sprite, complete: complete)
        case let movementEffect as MovementEffectComponent:
            applyMovementEffect(movementEffect, on: sprite, complete: complete)
        case let placementEffect as PlacementEffectComponent:
            applyPlacementEffect(placementEffect, by: sprite, complete: complete)
        case let playerHookEffect as PlayerHookEffectComponent:
            applyPlayerHookEffect(playerHookEffect, by: sprite, complete: complete)
        case let cutRopeEffect as CutRopeEffectComponent:
            applyCutRopeEffect(cutRopeEffect, by: sprite, complete: complete)
        case let stealEffect as StealPowerupEffectComponent:
            applyStealPowerupEffect(stealEffect, by: sprite, complete: complete)
        default:
            return
        }
    }
}

// MARK: - Apply Effects
extension PowerupSystem {
    private func applyStealPowerupEffect(_ effect: StealPowerupEffectComponent,
                                         by sprite: SpriteComponent,
                                         complete: () -> Void) {
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
        complete()
    }

    private func applyCutRopeEffect(_ effect: CutRopeEffectComponent,
                                    by sprite: SpriteComponent,
                                    complete: () -> Void) {
        let players = Array(ownedPowerups.keys).filter({
            $0 !== sprite && !isProtected(spriteComponent: $0, from: effect)
        })

        for player in players {
            delegate?.forceUnhookFor(player: player)
        }
        complete()
    }

    private func applyPlayerHookEffect(_ effect: PlayerHookEffectComponent,
                                       by sprite: SpriteComponent,
                                       complete: () -> Void) {
        guard let nearestSprite = sprite.nearestSpriteInFront(from: players) else {
            Logger.log.show(details: "No players to hook in front.", logType: .warning)
            return
        }
        guard !isProtected(spriteComponent: nearestSprite, from: effect) else {
            Logger.log.show(details: "Cannot hook onto shielded player",
                            logType: .warning)
            return
        }

        delegate?.forceUnhookFor(player: nearestSprite)
        delegate?.hook(nearestSprite, from: sprite)
        complete()
    }

    private func applyPlacementEffect(_ effect: PlacementEffectComponent,
                                      by sprite: SpriteComponent,
                                      complete: () -> Void) {
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
            complete()
        default:
            return
        }
    }

    private func applyMovementEffect(_ effect: MovementEffectComponent,
                                     on sprite: SpriteComponent,
                                     complete: @escaping () -> Void) {
        guard let initialPoint = effect.from,
            let endPoint = effect.to,
            let duration = effect.duration else {
                return
        }

        delegate?.movement(isDisabled: true, for: sprite)
        if effect.stopMovement {
            sprite.node.physicsBody?.velocity = CGVector.zero
            sprite.node.physicsBody?.affectedByGravity = false
        }
        sprite.node.position = initialPoint
        let action = SKAction.move(to: endPoint, duration: duration)
        sprite.node.run(action, completion: {
            sprite.node.physicsBody?.affectedByGravity = true
            effect.parent.get(SpriteComponent.self)?.node.removeFromParent()
            self.delegate?.movement(isDisabled: false, for: sprite)
            complete()
        })
    }

    private func applyShieldEffect(_ effect: ShieldEffectComponent,
                                   on sprite: SpriteComponent,
                                   complete: @escaping () -> Void) {
        let shieldTexture = SKTexture(imageNamed: "shield_bubble")
        let shieldSize = CGSize(width: sprite.node.size.width * 2,
                                height: sprite.node.size.height * 2)
        let shieldNode = SKSpriteNode(texture: shieldTexture,
                                      color: .clear,
                                      size: shieldSize)
        sprite.node.addChild(shieldNode)
        DispatchQueue.main.asyncAfter(deadline: .now() + effect.duration) {
            shieldNode.removeFromParent()
            complete()
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
