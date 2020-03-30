//
//  FinishingLineSystem.swift
//  Hookies
//
//  Created by JinYing on 30/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

protocol FinishingLineSystemProtocol {
    func stop(player: SpriteComponent) throws
}

enum FinishingLineSystemError: Error {
    case spriteDoesNotExist
}

class FinishingLineSystem: System, FinishingLineSystemProtocol {
    private let finishingLine: SpriteComponent
    private let players: Set<SpriteComponent>
    private var finishedPlayers: Int

    init(finishingLine: SpriteComponent, players: Set<SpriteComponent>) {
        self.finishingLine = finishingLine
        self.players = players
        self.finishedPlayers = 0
    }

    func stop(player: SpriteComponent) throws {
        guard let systemPlayer = players.first(where: { $0 == player }) else {
            throw FinishingLineSystemError.spriteDoesNotExist
        }

        bringToStop(sprite: systemPlayer)
        finishedPlayers += 1
    }

    private func bringToStop(sprite: SpriteComponent) {
        guard let velocity = sprite.node.physicsBody?.velocity else {
            return
        }

        let hasPlayerStop = velocity.dx <= 0.5 && velocity.dy <= 0.5

        if !hasPlayerStop {
            let oppositeForce = CGVector(dx: -velocity.dx, dy: -velocity.dy)
            sprite.node.physicsBody?.applyForce(oppositeForce)
            bringToStop(sprite: sprite)
        } else {
            sprite.node.physicsBody?.velocity = CGVector.zero
            sprite.node.physicsBody?.restitution = 0
        }
    }
}

extension FinishingLineSystem {
    func broadcastEndGameState(gameId: String, playersId: [String]) {
        let isAllPlayersFinished = players.count == finishedPlayers

        if isAllPlayersFinished {
            let gameplayEnd = Gameplay(gameId: gameId, gameState: .finish, playersId: playersId)

            API.shared.gameplay.saveGameState(gameplay: gameplayEnd)
            API.shared.gameplay.closeGameSession()
        }
    }
}
