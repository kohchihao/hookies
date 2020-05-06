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
    func collect(powerupNode: SKSpriteNode, by sprite: SpriteComponent)
    func activateTrap(at point: CGPoint, on sprite: SpriteComponent)
}

protocol PowerupSystemDelegate: MovementControlDelegate, SceneDelegate {

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
    private(set) var ownedPowerups = [SpriteComponent: [PowerupComponent]]()
    // Key: sprite of player, Value: activated powerups of player
    private(set) var activatedPowerups = [SpriteComponent: [PowerupComponent]]()
    // Powerups that has been activated and its sprite is placed on the map
    // waiting for players to contact it.
    private(set) var traps = Set<SpriteComponent>()

    private(set) var collectablePowerups = Set<PowerupComponent>()

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
        collectablePowerups.insert(powerup)
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
    ///   - powerupNode: The powerup sprite node to be collected
    ///   - sprite: The sprite that collects the powerup.
    func collect(powerupNode: SKSpriteNode, by sprite: SpriteComponent) {
        guard let powerupComponent = findCollectablePowerup(at: powerupNode.position) else {
            return
        }
        let powerupPos = Vector(point: powerupNode.position)
        let powerupType = powerupComponent.type
        let animatedNode = powerupType.animateRemoval(from: powerupNode.position)
        delegate?.hasAdded(node: animatedNode)
        collect(powerupComponent: powerupComponent, by: sprite)
        broadcastCollection(of: powerupComponent, by: sprite, at: powerupPos)
    }

    private func broadcastCollection(of powerup: PowerupComponent,
                                     by sprite: SpriteComponent,
                                     at position: Vector
    ) {
        let info = [
            "data": PowerupCollectionSystemEvent(sprite: sprite,
                                                 powerupPos: position,
                                                 powerupType: powerup.type)
        ]
        NotificationCenter.default.post(name: Notification.Name.broadcastPowerupCollectionEvent,
                                        object: nil,
                                        userInfo: info)
    }

    // MARK: - Activate Powerup

    /// Will activate the powerup that is owned by the sprite.
    /// Will also broadcast this event to other players.
    /// - Parameters:
    ///   - sprite: the sprite that triggers this activation.
    func activatePowerup(for sprite: SpriteComponent) {
        guard let powerup = powerup(for: sprite) else {
            return
        }

        activate(powerup, by: sprite)
        broadcastPowerup(eventType: .activate, by: sprite)
    }

    /// Will activate the trap event that is activated on the given sprite.
    /// Will also broadcast this event to other players.
    /// - Parameters:
    ///   - point: The point at which this activate occurs.
    ///   - sprite: The sprite that gets trap in the net
    func activateTrap(at point: CGPoint, on sprite: SpriteComponent) {
        guard let trap = findTrap(at: point) else {
            Logger.log.show(details: "Unable find trap", logType: .error)
            return
        }

        activate(trap: trap, on: sprite)
        broadcastPowerup(eventType: .activateTrap, by: sprite)
    }

    private func broadcastPowerup(eventType: PowerupEventType,
                                  by sprite: SpriteComponent
    ) {
        let position = Vector(point: sprite.node.position)
        let event = PowerupSystemEvent(sprite: sprite,
                                       powerupEventType: eventType,
                                       powerupPos: position)
        let info = [ "data": event ]
        let nameOfBroadcast = Notification.Name.broadcastPowerupAction
        NotificationCenter.default.post(name: nameOfBroadcast,
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

        removePowerup(from: player1)
        add(player: player2, with: powerupToSteal)
        delegate?.indicateSteal(from: player1, by: player2, with: powerupToSteal)
    }

    // MARK: Add player's Powerup

    private func add(player: SpriteComponent, with powerup: PowerupComponent) {
        removePowerup(from: player) // Ensure player will only own 1 powerup
        ownedPowerups[player]?.append(powerup)
        powerup.setOwner(player.parent)
    }

    // MARK: - Collect Powerup

    private func collect(powerupComponent: PowerupComponent,
                         by sprite: SpriteComponent
    ) {
        add(player: sprite, with: powerupComponent)
        remove(collectablePowerup: powerupComponent) { success in
            if success {
                powerupComponent.parent.removeComponents(SpriteComponent.self)
                self.delegate?.collected(powerup: powerupComponent, by: sprite)
            }
        }
    }

    private func remove(collectablePowerup: PowerupComponent,
                        complete: @escaping (_ success: Bool) -> Void
    ) {
        guard let powerupSprite = collectablePowerup.parent.get(SpriteComponent.self)
            else {
                return complete(false)
        }

        collectablePowerups.remove(collectablePowerup)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        powerupSprite.node.run(fade, completion: {
            powerupSprite.node.removeFromParent()
            complete(true)
        })
    }

    // MARK: - Find Trap

    /// Will find a trap at the given point if any.
    private func findTrap(at point: CGPoint) -> SpriteComponent? {
        for trap in traps where trap.node.frame.contains(point) {
            return trap
        }
        return nil
    }

    // MARK: - Find Powerup

    private func findCollectablePowerup(at point: CGPoint
    ) -> PowerupComponent? {
        for powerup in collectablePowerups {
            guard let sprite = powerup.parent.get(SpriteComponent.self) else {
                continue
            }
            if sprite.node.frame.contains(point) {
                return powerup
            }
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

    private func activate(trap: SpriteComponent, on sprite: SpriteComponent) {
        guard let powerup = trap.parent.get(PowerupComponent.self),
            let owner = powerup.owner else {
                Logger.log.show(details: "Unable find trap", logType: .error)
                return
        }

        if sprite.parent === owner {
            return
        }
        apply(powerup: powerup, on: sprite) { isSuccess in
            if isSuccess {
                self.traps.remove(trap)
            }
        }
    }

    // MARK: - Activate Powerup

    /// Will activate the powerup that is owned by the sprite.
    private func activate(_ powerup: PowerupComponent, by sprite: SpriteComponent) {
        guard let powerupEntity = powerup.parent as? PowerupEntity else {
            return
        }

        powerupEntity.activate()
        removePowerup(from: sprite)
        addActivated(powerup: powerup, to: sprite)
        apply(powerup: powerup, on: sprite)
        powerupEntity.postActivationHook()
    }

    /// Will apply the powerup on the sprite.
    private func apply(powerup: PowerupComponent,
                       on sprite: SpriteComponent,
                       complete: ((Bool) -> Void)? = nil
    ) {
        let effects = powerup.parent.getMultiple(PowerupEffectComponent.self)
        for effect in effects {
            apply(effect: effect, on: sprite) { isSuccess in
                self.removeActivated(powerup: powerup, from: sprite)
                if let complete = complete {
                    complete(isSuccess)
                }
            }
        }
    }

    /// Will apply the effect on the sprite
    private func apply(effect: PowerupEffectComponent,
                       on sprite: SpriteComponent,
                       complete: @escaping (_ success: Bool) -> Void
    ) {
        if isProtected(spriteComponent: sprite, from: effect) {
            complete(false)
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
                                         complete: (_ success: Bool) -> Void) {
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
        complete(true)
    }

    private func applyCutRopeEffect(_ effect: CutRopeEffectComponent,
                                    by sprite: SpriteComponent,
                                    complete: (_ success: Bool) -> Void) {
        let players = Array(ownedPowerups.keys).filter({
            $0 !== sprite && !isProtected(spriteComponent: $0, from: effect)
        })

        for player in players {
            delegate?.forceUnhookFor(player: player)
        }
        complete(true)
    }

    private func applyPlayerHookEffect(_ effect: PlayerHookEffectComponent,
                                       by sprite: SpriteComponent,
                                       complete: (_ success: Bool) -> Void) {
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
        complete(true)
    }

    private func applyPlacementEffect(_ effect: PlacementEffectComponent,
                                      by sprite: SpriteComponent,
                                      complete: (_ success: Bool) -> Void) {
        guard let effectSprite = effect.parent.get(SpriteComponent.self) else {
            return
        }

        effectSprite.node.position = sprite.node.position
        traps.insert(effectSprite)
        delegate?.hasAddedTrap(sprite: effectSprite)
        complete(true)
    }

    private func applyMovementEffect(_ effect: MovementEffectComponent,
                                     on sprite: SpriteComponent,
                                     complete: @escaping (_ success: Bool) -> Void) {
        guard let initialPoint = effect.from,
            let endPoint = effect.to,
            let duration = effect.duration else {
                complete(false)
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
            complete(true)
        })
    }

    private func applyShieldEffect(_ effect: ShieldEffectComponent,
                                   on sprite: SpriteComponent,
                                   complete: @escaping (_ success: Bool) -> Void) {
        let shieldTexture = SKTexture(imageNamed: "shield_bubble")
        let shieldSize = CGSize(width: sprite.node.size.width * 2,
                                height: sprite.node.size.height * 2)
        let shieldNode = SKSpriteNode(texture: shieldTexture,
                                      color: .clear,
                                      size: shieldSize)
        sprite.node.addChild(shieldNode)
        DispatchQueue.main.asyncAfter(deadline: .now() + effect.duration) {
            shieldNode.removeFromParent()
            complete(true)
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

        guard let powerup = findCollectablePowerup(at: positionOfCollection),
            let sprite = collectionEvent.sprite.parent.get(SpriteComponent.self)
            else {
                return
        }

        if let syncedPowerup = sync(powerup: powerup,
                                    with: collectionEvent.powerupType) {
            collect(powerupComponent: syncedPowerup, by: sprite)
        }
    }

    @objc private func receivedPowerupEventAction(_ notification: Notification) {
        guard let data = notification.userInfo as? [String: PowerupSystemEvent],
            let powerupEvent = data["data"] else {
                return
        }

        let playerSprite = powerupEvent.sprite
        switch powerupEvent.powerupEventType {
        case .activate:
            if let powerup = powerup(for: playerSprite) {
                activate(powerup, by: playerSprite)
            }
        case .activateTrap:
            let eventPos = CGPoint(vector: powerupEvent.powerupPos)
            if let trap = findTrap(at: eventPos) {
                activate(trap: trap, on: playerSprite)
            }
        }
    }

    @objc private func broadcastUnregisterObserver(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
    }

    private func sync(powerup: PowerupComponent,
                      with type: PowerupType
    ) -> PowerupComponent? {
        guard let powerupEntity = powerup.parent as? PowerupEntity else {
            return nil
        }
        let syncedPowerup = powerupEntity.sync(with: type)
        guard let newPowerupCom = syncedPowerup?.get(PowerupComponent.self) else {
            return nil
        }
        collectablePowerups.remove(powerup)
        collectablePowerups.insert(newPowerupCom)
        return newPowerupCom
    }
}
