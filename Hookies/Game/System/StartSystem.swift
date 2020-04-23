//
//  StartSystem.swift
//  Hookies
//
//  Created by Marcus Koh on 18/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

/// Start systems helps to check if the game is ready to start

protocol StartSystemProtocol {
    func add(player: Player, with sprite: SpriteComponent)
    func add(players: [Player], with sprites: [SpriteComponent])
}

protocol StartSystemDelegate: AnyObject {
    func isReadyToStart()
}

class StartSystem: System, StartSystemProtocol {

    private var totalNumberOfPlayers = 1 {
        didSet {
            if totalNumberOfPlayers == expectedNumberOfPlayers {
                delegate?.isReadyToStart()
            }
        }
    }

    private var expectedNumberOfPlayers: Int {
        return players.filter({ $0.key.playerType == .human }).count
    }

    private var players: [Player: SpriteComponent] = [:]
    weak var delegate: StartSystemDelegate?

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedOtherPlayerJoinEvent(_:)),
            name: .receivedOtherPlayerJoinEvent,
            object: nil)
    }

    func add(player: Player, with sprite: SpriteComponent) {
        players[player] = sprite
        broadcast()
    }

    func add(players: [Player], with sprites: [SpriteComponent]) {
        for (index, player) in players.enumerated() {
            self.players[player] = sprites[index]
        }
        broadcast()
    }

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

    private func broadcast() {
        NotificationCenter.default.post(
            name: .addPlayersMapping,
            object: self,
            userInfo: players)
    }

    @objc private func receivedOtherPlayerJoinEvent(_ notification: Notification) {
        totalNumberOfPlayers += 1
    }
}
