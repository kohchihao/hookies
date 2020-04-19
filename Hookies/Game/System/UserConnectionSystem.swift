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

protocol UserConnectionSystemDelegate: AnyObject {
    func userConnected()
    func userDisconnected()
}

class UserConnectionSystem: System, UserConnectionSystemProtocol {
    weak var delegate: UserConnectionSystemDelegate?

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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedCurrentPlayerRejoinEvent(_:)),
            name: .receivedCurrentPlayerRejoinEvent,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedCurrentPlayerDisconnectedEvent(_:)),
            name: .receivedCurrentPlayerDisconnectedEvent,
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

    @objc private func receivedCurrentPlayerRejoinEvent(_ notification: Notification) {
        delegate?.userConnected()
    }

    @objc private func receivedCurrentPlayerDisconnectedEvent(_ notification: Notification) {
        delegate?.userDisconnected()
    }
}
