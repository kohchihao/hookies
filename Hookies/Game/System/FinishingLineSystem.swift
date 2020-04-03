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
    func stop(player: SpriteComponent, at position: CGPoint) -> Bool
    func bringPlayersToStop()
}

enum FinishingLineSystemError: Error {
    case spriteDoesNotExist
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
    private var finishedPlayers: Int

    init(finishingLine: SpriteComponent, players: Set<SpriteComponent>) {
        self.finishingLine = finishingLine
        self.players = players
        self.finishedPlayers = 0
        self.playersState = [SpriteComponent: PlayerState]()
    }

    init(finishingLine: SpriteComponent) {
        self.finishingLine = finishingLine
        self.players = Set<SpriteComponent>()
        self.finishedPlayers = 0
        self.playersState = [SpriteComponent: PlayerState]()
    }

    func add(player: SpriteComponent) {
        players.insert(player)
        playersState[player] = .moving
    }

    func stop(player: SpriteComponent) -> Bool {
        guard let systemPlayer = players.first(where: { $0 == player }) else {
            return false
        }

        playersState[systemPlayer] = .stopping
        finishedPlayers += 1

        return true
    }

    func stop(player: SpriteComponent, at position: CGPoint) -> Bool {
        guard let systemPlayer = players.first(where: { $0 == player }) else {
            return false
        }

        systemPlayer.node.position = position

        playersState[systemPlayer] = .stopping
        finishedPlayers += 1

        return true
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

    func hasAllPlayersReachedFinishingLine() -> Bool {
        let isAllPlayersFinished = !players.isEmpty && players.count == finishedPlayers

        if isAllPlayersFinished {
            return true
        }

        return false
    }
}

// MARK: - Broadcast Update

extension FinishingLineSystem: GenericPlayerEventBroadcast {
    func broadcastUpdate(gameId: String, playerId: String, player: PlayerEntity) {
        broadcastUpdate(gameId: gameId, playerId: playerId, player: player, eventType: .reachedFinishedLine)
    }
}
