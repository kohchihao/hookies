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

    /// Indicates that the power up has been collected
    /// - Parameters:
    ///   - powerup: The power up collected
    ///   - sprite: The sprite that colelcted the power up
    func collected(powerup: PowerupComponent, by sprite: SpriteComponent)

    /// Removes the powerup from ownership
    /// - Parameter powerup: the powerup to be removed from ownership
    func didRemoveOwned(powerup: PowerupComponent)
}

class PowerupSystem: System, PowerupSystemProtocol {
    weak var delegate: PowerupSystemDelegate?

    // Key: sprite of player, Value: powerups of player
    private(set) var ownedPowerups = [SpriteComponent: [PowerupComponent]]()
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
    }

    // MARK: - Add Trap

    func add(trap: SpriteComponent) {
        traps.insert(trap)
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
        delegate?.didRemoveOwned(powerup: powerupToRemove)
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
        let animatedNode = powerupType.animateRemoval(from: powerupNode.position) {
            self.collect(powerupComponent: powerupComponent, by: sprite)
        }
        delegate?.hasAdded(node: animatedNode)
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
        guard let trap = findTrap(at: point),
            let trapSprite = trap.parent.get(SpriteComponent.self),
            let owner = trap.parent.get(PowerupComponent.self)?.owner else {
            Logger.log.show(details: "Unable find trap", logType: .error)
            return
        }

        if sprite.parent === owner {
            return
        }

        activate(trap: trap, on: sprite)
        broadcastPowerup(eventType: .activateTrap, by: sprite,
                         at: trapSprite.node.position)
    }

    private func broadcastPowerup(eventType: PowerupEventType,
                                  by sprite: SpriteComponent,
                                  at position: CGPoint? = nil
    ) {
        var eventPos: Vector
        eventPos = position != nil ? Vector(point: position!)
            : Vector(point: sprite.node.position)
        let event = PowerupSystemEvent(sprite: sprite,
                                       powerupEventType: eventType,
                                       powerupPos: eventPos)
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

    // MARK: Add player's Powerup

    func add(player: SpriteComponent, with powerup: PowerupComponent) {
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

    // MARK: - Activate Net Trap

    private func activate(trap: SpriteComponent, on sprite: SpriteComponent) {
        guard let trapEntity = trap.parent as? TrapEntity else {
            return
        }

        trapEntity.activateTrap(on: sprite)
        guard let effect = sprite.parent.get(PowerupEffectComponent.self) else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + effect.duration) {
            self.remove(trap: trap)
        }
    }

    private func remove(trap: SpriteComponent) {
        guard let trapSprite = trap.parent.get(SpriteComponent.self) else {
            return
        }
        trapSprite.node.removeFromParent()
        trap.parent.removeFirstComponent(of: trapSprite)
        self.traps.remove(trap)
    }

    // MARK: - Activate Powerup

    /// Will activate the powerup that is owned by the sprite.
    private func activate(_ powerup: PowerupComponent,
                          by sprite: SpriteComponent) {
        guard let powerupEntity = powerup.parent as? PowerupEntity else {
            return
        }

        powerupEntity.activate()
        let powerupDuration = powerupEntity.getMaxEffectDuration()
        DispatchQueue.main.asyncAfter(deadline: .now() + powerupDuration) {
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
