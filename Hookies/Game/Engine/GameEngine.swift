//
//  GameEngine.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

class GameEngine {
    private let gameId: String
    private var currentPlayerId: String?
    private var totalNumberOfPlayers = 0

    // MARK: - System

    private let spriteSystem = SpriteSystem()
    private var gameObjectMovementSystem = GameObjectMovementSystem()
    private var cannonSystem: CannonSystem!
    private var finishingLineSystem: FinishingLineSystem!
    private var hookSystem: HookSystem?
    private var closestBoltSystem: ClosestBoltSystem?
    private var deadLockSystem: DeadlockSystem?

    // MARK: - Entity

    private var currentPlayer: PlayerEntity?
    private var otherPlayers = [String: PlayerEntity]()
    private var platforms = [PlatformEntity]()
    private var bolts = [BoltEntity]()
    private var cannon = CannonEntity()
    private var finishingLine = FinishingLineEntity()

    init(
        gameId: String,
        cannon: SKSpriteNode,
        finishingLine: SKSpriteNode,
        bolts: [SKSpriteNode]
    ) {
        self.gameId = gameId

        let boltsSprite = initialiseBolts(bolts)

        self.hookSystem = HookSystem(bolts: boltsSprite)
        self.closestBoltSystem = ClosestBoltSystem(bolts: boltsSprite)

        let cannonSprite = createCannonSprite(from: cannon)
        self.cannonSystem = CannonSystem(cannon: cannonSprite)

        let finishingLineSprite = createFinishingLineSprite(from: finishingLine)
        self.finishingLineSystem = FinishingLineSystem(finishingLine: finishingLineSprite)

        setupMultiplayer()
    }

    // MARK: - Players

    func setCurrentPlayer(id: String, position: CGPoint, image: String) {
        let player = PlayerEntity()

        let sprite = SpriteComponent(parent: player)
        _ = spriteSystem.set(sprite: sprite, of: .player1, with: image, at: position)
        _ = spriteSystem.setPhysicsBody(to: sprite, of: .player1, rectangleOf: sprite.node.size)
        player.addComponent(sprite)

        addPlayerComponents(to: player)

        currentPlayerId = id
        currentPlayer = player

        deadLockSystem = DeadlockSystem(sprite: sprite)
        finishingLineSystem.add(player: sprite)
    }

    func addOtherPlayers(id: String, position: CGPoint, image: String) {
        let otherPlayer = PlayerEntity()

        let sprite = SpriteComponent(parent: otherPlayer)
        let spriteType = getOtherPlayerSpriteType()
        _ = spriteSystem.set(sprite: sprite, of: spriteType, with: image, at: position)
        _ = spriteSystem.setPhysicsBody(to: sprite, of: spriteType, rectangleOf: sprite.node.size)
        otherPlayer.addComponent(sprite)

        addPlayerComponents(to: otherPlayer)

        otherPlayers[id] = otherPlayer

        finishingLineSystem.add(player: sprite)
    }

    // MARK: - Bolts

    private func initialiseBolts(_ bolts: [SKSpriteNode]) -> [SpriteComponent] {
        var boltsSprite = [SpriteComponent]()

        for bolt in bolts {
            let boltEntity = BoltEntity()

            let boltSprite = SpriteComponent(parent: boltEntity)
            _ = spriteSystem.set(sprite: boltSprite, to: bolt)

            // TODO: Check for moving and rotating bolt

            boltEntity.addComponent(boltSprite)

            boltsSprite.append(boltSprite)
            self.bolts.append(boltEntity)
        }

        return boltsSprite
    }

    // MARK: - Cannon

    private func createCannonSprite(from node: SKSpriteNode) -> SpriteComponent {
        let sprite = SpriteComponent(parent: cannon)
        _ = spriteSystem.set(sprite: sprite, to: node)

        cannon.addComponent(sprite)

        return sprite
    }

    // MARK: - Finishing Line

    private func createFinishingLineSprite(from node: SKSpriteNode) -> SpriteComponent {
        let sprite = SpriteComponent(parent: finishingLine)
        _ = spriteSystem.set(sprite: sprite, to: node)
        _ = spriteSystem.setPhysicsBody(to: sprite, of: .finishingLine, rectangleOf: sprite.node.size)

        self.finishingLine.addComponent(sprite)

        return sprite
    }

    // MARK: - Player helper methods

    private func addPlayerComponents(to player: PlayerEntity) {
        let hook = HookComponent(parent: player)

        player.addComponent(hook)
        _ = hookSystem?.add(hook: hook)
    }

    private func getOtherPlayerSpriteType() -> SpriteType {
        let numOtherPlayers = otherPlayers.count
        let typeIndex = numOtherPlayers + 1

        return SpriteType.otherPlayers[typeIndex]
    }

    private func playerHookAction(player: PlayerEntity) {
        guard let hook = getHookComponent(from: player) else {
            return
        }

        do {
            try hookSystem?.hookTo(hook: hook)
        } catch HookSystemError.hookComponentDoesNotExist {
            print(HookSystemError.hookComponentDoesNotExist)
            return
        } catch HookSystemError.spriteComponentDoesNotExist {
            print(HookSystemError.spriteComponentDoesNotExist)
            return
        } catch HookSystemError.closestHookToEntityDoesNotExist {
            print(HookSystemError.closestHookToEntityDoesNotExist)
            return
        } catch HookSystemError.physicsBodyDoesNotExist {
            print(HookSystemError.physicsBodyDoesNotExist)
            return
        } catch {
            print("Unexpected error: \(error)")
            return
        }
    }

    // MARK: - Multiplayer

    private func setupMultiplayer() {
        setupTotalPlayers()
        connectToGame()
        subscribeToOtherPlayersState()
        subscribeToHookAction()
        subscribeToPowerupAction()
    }

    private func setupTotalPlayers() {
        API.shared.lobby.get(lobbyId: self.gameId, completion: { lobby, error in
            if error != nil {
                return
            }

            guard let lobby = lobby else {
                return
            }

            self.totalNumberOfPlayers = lobby.playersId.count
        })
    }

    private func connectToGame() {
        API.shared.gameplay.connectToGame(gameId: gameId, completion: { otherPlayersId in
            for otherPlayerId in otherPlayersId {
                self.setupPlayer(of: otherPlayerId)
            }

            self.startGame()
        })
    }

    private func subscribeToOtherPlayersState() {
        API.shared.gameplay.subscribeToPlayersConnection(listener: { userConnection in
            if userConnection.state == .connected {
                self.setupPlayer(of: userConnection.uid)
                self.startGame()
            }

            // TODO: Setup Disconnected
        })
    }

    private func setupPlayer(of id: String) {
        API.shared.lobby.get(lobbyId: self.gameId, completion: { lobby, error in
            if error != nil {
                return
            }

            guard let costume = lobby?.costumesId[id] else {
                return
            }

            guard let initialPosition = self.getSpriteComponent(from: self.cannon)?.node.position else {
                return
            }

            self.addOtherPlayers(id: id, position: initialPosition, image: costume.stringValue)
        })
    }

    private func subscribeToHookAction() {
        API.shared.gameplay.subscribeToHookAction(listener: { hookActionData in
            guard let player = self.otherPlayers[hookActionData.playerData.playerId] else {
                return
            }

            switch hookActionData.actionType {
            case .activate:
                self.playerHookAction(player: player)
            case .deactivate:
                do {
                    try self.hookSystem?.unhookFrom(entity: player)
                } catch HookSystemError.hookComponentDoesNotExist {
                    print(HookSystemError.hookComponentDoesNotExist)
                    return
                } catch {
                    print("Unexpected error: \(error)")
                    return
                }
            }
        })
    }

    private func subscribeToPowerupAction() {
        API.shared.gameplay.subscribeToPowerupAction(listener: { powerupAction in
            // TODO: Add implementation
        })
    }

    private func startGame() {
        let isAllPlayerInGame = totalNumberOfPlayers != 0 && totalNumberOfPlayers == otherPlayers.count + 1

        if isAllPlayerInGame {
            // TOOD: Delegate to Game Scene
            print("start game")
        }
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

    private func getHookComponent(from entity: Entity) -> HookComponent? {
        for component in entity.components {
            if let hook = component as? HookComponent {
                return hook
            }
        }

        return nil
    }
}
