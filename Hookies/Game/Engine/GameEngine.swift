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

    // MARK: - PlayerEntities

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
    }

    private func addCommonPlayerComponents(to player: PlayerEntity) {
        let hook = HookComponent(parent: player)

        player.addComponent(hook)
    }

    private func getOtherPlayerSpriteType() -> SpriteType {
        let numOtherPlayers = otherPlayers.count
        let typeIndex = numOtherPlayers + 1

        return SpriteType.otherPlayers[typeIndex]
    }
}
