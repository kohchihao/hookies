//
//  GameEngine.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

class GameEngine {
    let gameId: String
    private var currentPlayerId: String?

    // MARK: - System
    let spriteSystem: SpriteSystem
    private var hookSystem: HookSystem?
    private var deadLockSystem: DeadlockSystem?
    private var gameObjectMovementSystem: GameObjectMovementSystem?
    private var finishingLineSystem: FinishingLineSystem?

    // MARK: - Entity
    private var currentPlayer: PlayerEntity?
    private var otherPlayers: [PlayerEntity]
    private var platforms: [PlatformEntity]
    private var collectables: [CollectableEntity]
    private var bolts: [BoltEntity]
    private var finishingLine: FinishingLineEntity?

    init(gameId: String) {
        self.gameId = gameId

        spriteSystem = SpriteSystem()

        otherPlayers = [PlayerEntity]()
        platforms = [PlatformEntity]()
        collectables = [CollectableEntity]()
        bolts = [BoltEntity]()
    }

    // MARK: - Players

    func setCurrentPlayer(id: String, position: CGPoint, image: String) {
        let player = PlayerEntity()

        let sprite = SpriteComponent(parent: player)
        _ = spriteSystem.set(sprite: sprite, of: .player1, with: image, at: position)
        _ = spriteSystem.setPhysicsBody(to: sprite, of: .player1, rectangleOf: sprite.node.size)
        player.addComponent(sprite)

        addCommonPlayerComponents(to: player)

        currentPlayerId = id
        currentPlayer = player

        // TODO: Init Deadlock System?

        addPlayerToFinishingLine(with: sprite)
    }

    func addOtherPlayers(position: CGPoint, image: String) {
        let otherPlayer = PlayerEntity()

        let sprite = SpriteComponent(parent: otherPlayer)
        let spriteType = getOtherPlayerSpriteType()
        _ = spriteSystem.set(sprite: sprite, of: spriteType, with: image, at: position)
        _ = spriteSystem.setPhysicsBody(to: sprite, of: spriteType, rectangleOf: sprite.node.size)
        otherPlayer.addComponent(sprite)

        addCommonPlayerComponents(to: otherPlayer)

        otherPlayers.append(otherPlayer)

        addPlayerToFinishingLine(with: sprite)
    }

    // MARK: - Finishing Line
    func setFinishingLine(node: SKSpriteNode) {
        let finishingLine = FinishingLineEntity()

        let sprite = SpriteComponent(parent: finishingLine)
        _ = spriteSystem.set(sprite: sprite, to: node)
        _ = spriteSystem.setPhysicsBody(to: sprite, of: .finishingLine, rectangleOf: sprite.node.size)

        self.finishingLine = finishingLine

        initialiseFinishingLineSystem(with: sprite)
    }

    // MARK: - Player helper methods

    private func addCommonPlayerComponents(to player: PlayerEntity) {
        let hook = HookComponent(parent: player)

        player.addComponent(hook)
    }

    private func getOtherPlayerSpriteType() -> SpriteType {
        let numOtherPlayers = otherPlayers.count
        let typeIndex = numOtherPlayers + 1

        return SpriteType.otherPlayers[typeIndex]
    }

    // MARK: - Finishing line helper methods

    private func initialiseFinishingLineSystem(with sprite: SpriteComponent) {
        if let currentPlayer = self.currentPlayer {
            // Assumption that all players are set before finishing line

            var playersSprite = Set<SpriteComponent>()

            guard let currentPlayerSprite = getSpriteComponent(from: currentPlayer) else {
                return
            }
            playersSprite.insert(currentPlayerSprite)

            for otherPlayer in otherPlayers {
                guard let otherPlayerSprite = getSpriteComponent(from: otherPlayer) else {
                    return
                }
                playersSprite.insert(otherPlayerSprite)
            }

            finishingLineSystem = FinishingLineSystem(finishingLine: sprite, players: playersSprite)
        } else {
            finishingLineSystem = FinishingLineSystem(finishingLine: sprite)
        }
    }

    private func addPlayerToFinishingLine(with sprite: SpriteComponent) {
        guard let finishingLineSystem = self.finishingLineSystem else {
            return
        }

        finishingLineSystem.add(player: sprite)
    }

    // MARK: - General helper methods

    private func getSpriteComponent(from entity: Entity) -> SpriteComponent? {
        for component in entity.components {
            if let sprite = component as? SpriteComponent {
                return sprite
            }
        }

        return nil
    }
}
