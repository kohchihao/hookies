//
//  CannonSystem.swift
//  Hookies
//
//  Created by JinYing on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

protocol CannonSystemProtocol {
    func launch(player: SpriteComponent, with velocity: CGVector)
}

class CannonSystem: System, CannonSystemProtocol {
    private let cannon: SpriteComponent

    init(cannon: SpriteComponent) {
        self.cannon = cannon
        registerNotificationObservers()
    }

    /// Launch for single player
    func launch(player: SpriteComponent, with velocity: CGVector) {
        player.node.physicsBody?.isDynamic = true
        player.node.physicsBody?.applyImpulse(velocity)

        broadcast(with: player)
    }

    /// Launch for multiplayer
    private func launch(otherPlayer: SpriteComponent, with velocity: CGVector) {
        otherPlayer.node.physicsBody?.isDynamic = true
        otherPlayer.node.physicsBody?.velocity = velocity
    }
}

// MARK: - Networking

extension CannonSystem {
    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedLaunchAction(_:)),
            name: .receivedLaunchAction,
            object: nil)
    }

    private func broadcast(with sprite: SpriteComponent) {
        let genericSystemEvent = GenericSystemEvent(sprite: sprite, eventType: .shotFromCannon)
        NotificationCenter.default.post(
            name: .broadcastGenericPlayerAction,
            object: self,
            userInfo: ["data": genericSystemEvent])
    }

    @objc private func receivedLaunchAction(_ notification: Notification) {
        if let data = notification.userInfo as? [String: GenericSystemEvent] {
            guard let genericSystemEvent = data["data"] else {
                return
            }

            let sprite = genericSystemEvent.sprite
            guard let velocity = sprite.node.physicsBody?.velocity else {
                return
            }

            launch(otherPlayer: sprite, with: velocity)
        }
    }
}
