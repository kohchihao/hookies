//
//  FinishingLineSystem.swift
//  Hookies
//
//  Created by JinYing on 30/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

protocol FinishingLineSystemProtocol {
    func stop(player: SpriteComponent) -> Bool
    func bringPlayersToStop()
}

enum PlayerState {
    case moving
    case stopping
    case stopped
}

class FinishingLineSystem: System, FinishingLineSystemProtocol {
    private let finishingLine: SpriteComponent
    private var players: Set<SpriteComponent>
    private var playersState: [SpriteComponent: PlayerState]

    init(finishingLine: SpriteComponent, players: Set<SpriteComponent>) {
        self.finishingLine = finishingLine
        self.players = players
        self.playersState = [SpriteComponent: PlayerState]()

        registerNotificationObservers()
    }

    init(finishingLine: SpriteComponent) {
        self.finishingLine = finishingLine
        self.players = Set<SpriteComponent>()
        self.playersState = [SpriteComponent: PlayerState]()

        registerNotificationObservers()
    }

    func add(player: SpriteComponent) {
        players.insert(player)
        playersState[player] = .moving
    }

    func remove(player: SpriteComponent) {
        players.remove(player)
        playersState[player] = nil
    }

    /// Stop for single player
    func stop(player: SpriteComponent) -> Bool {
        guard let velocity = player.node.physicsBody?.velocity else {
            return false
        }

        broadcastReachedFinishLine(with: player)
        broadcastFinishGame(with: player)
        return stop(player: player, at: player.node.position, with: velocity)
    }

    func bringPlayersToStop() {
        for (sprite, state) in playersState where state == .stopping {
            guard let velocity = sprite.node.physicsBody?.velocity else {
                return
            }

            let hasPlayerStop = velocity.dx <= 0.5 && velocity.dy <= 0.5

            if !hasPlayerStop {
                let oppositeForce = CGVector(dx: -velocity.dx, dy: -velocity.dy)
                sprite.node.physicsBody?.applyForce(oppositeForce)
            } else {
                sprite.node.physicsBody?.velocity = CGVector.zero
                sprite.node.physicsBody?.restitution = 0
                sprite.node.physicsBody?.isDynamic = false

                playersState[sprite] = .stopped
            }
        }
    }

    func hasPlayerFinish(player: SpriteComponent) -> Bool {
        guard let state = playersState[player] else {
            return false
        }

        return state != .moving
    }

    /// Stop for multiplayer
    private func stop(player: SpriteComponent, at position: CGPoint, with velocity: CGVector) -> Bool {
        guard let systemPlayer = players.first(where: { $0 == player }) else {
            return false
        }

        systemPlayer.node.position = position
        systemPlayer.node.physicsBody?.velocity = velocity

        playersState[systemPlayer] = .stopping

        return true
    }
}

// MARK: Networking

extension FinishingLineSystem {
    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedReachedFinishLineAction(_:)),
            name: .receivedReachedFinishLineAction,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(broadcastUnregisterObserver(_:)),
            name: .broadcastUnregisterObserver,
            object: nil)
    }

    private func broadcastReachedFinishLine(with sprite: SpriteComponent) {
        let genericSystemEvent = GenericSystemEvent(sprite: sprite, eventType: .reachedFinishedLine)
        NotificationCenter.default.post(
            name: .broadcastGenericPlayerAction,
            object: self,
            userInfo: ["data": genericSystemEvent])
    }

    private func broadcastFinishGame(with sprite: SpriteComponent) {
        NotificationCenter.default.post(name: .broadcastFinishGameEvent, object: self, userInfo: ["data": sprite])
    }

    @objc private func receivedReachedFinishLineAction(_ notification: Notification) {
        if let data = notification.userInfo as? [String: GenericSystemEvent] {
            guard let genericSystemEvent = data["data"] else {
                return
            }

            let sprite = genericSystemEvent.sprite
            guard let velocity = sprite.node.physicsBody?.velocity else {
                return
            }
            _ = stop(player: sprite, at: sprite.node.position, with: velocity)
        }
    }

    @objc private func broadcastUnregisterObserver(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
    }
}
