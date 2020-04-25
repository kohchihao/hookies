//
//  StartSystem.swift
//  Hookies
//
//  Created by Marcus Koh on 18/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol StartSystemProtocol {
    func add(player: Player, with sprite: SpriteComponent)
    func add(players: [Player], with sprites: [SpriteComponent])
}

protocol StartSystemDelegate: AnyObject {
    /// Indicates that the game is ready to start
    func isReadyToStart()
}

/// Start systems helps to check if the game is ready to start

class StartSystem: System, StartSystemProtocol {

    private var totalNumberOfPlayers = 1 {
        didSet {
            if totalNumberOfPlayers == expectedNumberOfPlayers {
                delegate?.isReadyToStart()
            }
        }
    }

    private var expectedNumberOfPlayers: Int {
        return players.count
    }

    private var players: [Player: SpriteComponent] = [:]
    weak var delegate: StartSystemDelegate?

    init() {
        registerNotificationObservers()
    }

    /// Add a player with its sprite component to the system
    /// - Parameters:
    ///   - player: the player model
    ///   - sprite: the player's SpriteComponent
    func add(player: Player, with sprite: SpriteComponent) {
        players[player] = sprite
        broadcast()
    }

    /// Add a list of players with their sprite component to the system
    /// - Parameters:
    ///   - players: a list of player models
    ///   - sprites: a list player's SpriteCompnent.
    ///              A players's SpriteComponent should be in the same order as the player's model.
    func add(players: [Player], with sprites: [SpriteComponent]) {
        guard players.count == sprites.count else {
            Logger.log.show(details: "Size does not match", logType: .error)
            return
        }

        for (index, player) in players.enumerated() {
            self.players[player] = sprites[index]
        }
        broadcast()
    }

    /// Handles the start of the game
    func getReady() {
        if expectedNumberOfPlayers == 1 {
            delegate?.isReadyToStart()
        }
        NotificationCenter.default.post(
            name: .gameConnectionEvent,
            object: self,
            userInfo: nil)
    }
}

// MARK: - Networking

extension StartSystem {
    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedOtherPlayerJoinEvent(_:)),
            name: .receivedOtherPlayerJoinEvent,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(broadcastUnregisterObserver(_:)),
            name: .broadcastUnregisterObserver,
            object: nil)
    }

    /// Broadcast to Notification Center
    private func broadcast() {
        NotificationCenter.default.post(
            name: .addPlayersMapping,
            object: self,
            userInfo: players)
    }

    @objc private func receivedOtherPlayerJoinEvent(_ notification: Notification) {
        totalNumberOfPlayers += 1
    }

    @objc private func broadcastUnregisterObserver(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
    }
}
