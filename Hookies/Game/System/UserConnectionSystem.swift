//
//  UserConnectionSystem.swift
//  Hookies
//
//  Created by JinYing on 4/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol UserConnectionSystemProtocol {

}

class UserConnectionSystem: System, UserConnectionSystemProtocol {
    init() {
        registerNotificationObservers()
    }

    private func disconnect(sprite: SpriteComponent) {
        sprite.node.physicsBody?.isDynamic = false
    }

    private func reconnect(sprite: SpriteComponent) {
        sprite.node.physicsBody?.isDynamic = true
    }
}

extension UserConnectionSystem {
    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedOtherPlayerRejoinEvent(_:)),
            name: .receivedOtherPlayerRejoinEvent,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedOtherPlayerDisconnectedEvent(_:)),
            name: .receivedOtherPlayerDisconnectedEvent,
            object: nil)
    }

    @objc private func receivedOtherPlayerRejoinEvent(_ notification: Notification) {
        if let data = notification.userInfo as? [String: SpriteComponent] {
            guard let sprite = data["data"] else {
                return
            }

            reconnect(sprite: sprite)
        }
    }

    @objc private func receivedOtherPlayerDisconnectedEvent(_ notification: Notification) {
        if let data = notification.userInfo as? [String: SpriteComponent] {
            guard let sprite = data["data"] else {
                return
            }

            disconnect(sprite: sprite)
        }
    }
}
