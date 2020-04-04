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
    private var gameState: GameState = .waiting
    private var currentPlayerId: String?
    private var totalNumberOfPlayers = 0

    weak var delegate: GameEngineDelegate?

    // MARK: - System

    private let spriteSystem = SpriteSystem()
    private var gameObjectMovementSystem = GameObjectMovementSystem()
    private var collectableSystem = CollectableSystem()
    private var cannonSystem: CannonSystem!
    private var finishingLineSystem: FinishingLineSystem!
    private var hookSystem: HookSystem?
    private var closestBoltSystem: ClosestBoltSystem?
    private var deadLockSystem: DeadlockSystem?
    private var powerupSystem = PowerupSystem()
    private var powerupEffectSystem = PowerupEffectSystem()

    // MARK: - Entity

    private var currentPlayer: PlayerEntity?
    private var otherPlayers = [String: PlayerEntity]()
    private var platforms = [PlatformEntity]()
    private var bolts = [BoltEntity]()
    private var powerups = [SKSpriteNode: PowerupEntity]()
    private var cannon = CannonEntity()
    private var finishingLine = FinishingLineEntity()

    init(
        gameId: String,
        cannon: SKSpriteNode,
        finishingLine: SKSpriteNode,
        bolts: [SKSpriteNode],
        powerups: [SKSpriteNode]
    ) {
        self.gameId = gameId

        let boltsSprite = initialiseBolts(bolts)
        initialisePowerups(powerups)
        powerupSystem.delegate = self

        self.hookSystem = HookSystem(bolts: boltsSprite)
        self.closestBoltSystem = ClosestBoltSystem(bolts: boltsSprite)

        let cannonSprite = createCannonSprite(from: cannon)
        self.cannonSystem = CannonSystem(cannon: cannonSprite)

        let finishingLineSprite = createFinishingLineSprite(from: finishingLine)
        self.finishingLineSystem = FinishingLineSystem(finishingLine: finishingLineSprite)

        setupTotalPlayers()
        connectToGame()
        setupMultiplayer()
    }

    // MARK: - Initialise Players

    func setCurrentPlayer(id: String, position: CGPoint, image: String) -> SKSpriteNode {
        let player = PlayerEntity()

        let sprite = SpriteComponent(parent: player)
        _ = spriteSystem.set(sprite: sprite, of: .player1, with: image, at: position)
        _ = spriteSystem.setPhysicsBody(to: sprite, of: .player1, rectangleOf: sprite.node.size)
        player.addComponent(sprite)

        addPlayerComponents(to: player)

        currentPlayerId = id
        currentPlayer = player
        powerupEffectSystem.addPlayerSprite(playerId: id, sprite)

        deadLockSystem = DeadlockSystem(sprite: sprite)
        finishingLineSystem.add(player: sprite)

        return sprite.node
    }

    // MARK: - Launch Current Player

    func launchCurrentPlayer(with velocity: CGVector) {
        guard let currentPlayerId = currentPlayerId,
            let currentPlayer = currentPlayer else {
            return
        }

        guard let sprite = currentPlayer.getSpriteComponent() else {
            return
        }

        cannonSystem.launch(player: sprite, with: velocity)
        cannonSystem.broadcastUpdate(gameId: gameId, playerId: currentPlayerId, player: currentPlayer)
    }

    // MARK: - Start Game

    func startGame() {
        gameState = .start
    }

    // MARK: - Current Player Hook Action

    func currentPlayerHookAction() {
        guard let currentPlayerId = currentPlayerId,
            let currentPlayer = currentPlayer else {
            return
        }

        playerHookAction(player: currentPlayer)
        hookSystem?.broadcastUpdate(gameId: gameId, playerId: currentPlayerId, player: currentPlayer, type: .activate)
    }

    func currentPlayerUnhookAction() {
        guard let currentPlayerId = currentPlayerId,
            let currentPlayer = currentPlayer else {
            return
        }

        playerUnhookAction(player: currentPlayer)
        hookSystem?.broadcastUpdate(gameId: gameId, playerId: currentPlayerId, player: currentPlayer, type: .deactivate)
    }

    // MARK: - Current Player Powerup Action

    func currentPlayerPowerupAction(with type: PowerupType) {
        guard let currentPlayer = currentPlayer else {
            return
        }

        playerPowerupAction(with: type, for: currentPlayer)
//        hookSystem?.broadcastUpdate(gameId: gameId, playerId: currentPlayerId, player: currentPlayer, type: .activate)
    }

    // MARK: - Current Player Jump Action

    func currentPlayerJumpAction() {
        guard let currentPlayerId = currentPlayerId,
            let currentPlayer = currentPlayer else {
            return
        }

        guard let sprite = currentPlayer.getSpriteComponent() else {
            return
        }

        sprite.node.physicsBody?.applyImpulse(CGVector(dx: 500, dy: 500))
        deadLockSystem?.broadcastUpdate(gameId: gameId, playerId: currentPlayerId, player: currentPlayer)
    }

    // MARK: - Contact with Collectables

    func playerContactWith(powerup: SKSpriteNode, playerId: String?) -> PowerupType? {
        guard let playerId = playerId,
            let currentPlayer = currentPlayer,
            let powerupEntity = powerups[powerup],
            let sprite = powerupEntity.getSpriteComponent(),
            let powerupIndex = powerups.index(forKey: sprite.node) else {
                return nil
        }

        guard let powerupComponent = collectableSystem.collect(powerup: powerupEntity, playerId: playerId) else {
            return nil
        }

        spriteSystem.removePhysicsBody(to: sprite)
        powerups.remove(at: powerupIndex)
        powerupSystem.add(player: currentPlayer, with: powerupComponent)
//        respawnPowerup(powerup)
        return powerupComponent.type
    }

    // MARK: - Update

    func update(time: TimeInterval) {
        startCountdown()
        checkDeadlock()
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

    // MARK: - Power ups

    private func initialisePowerups(_ powerups: [SKSpriteNode]) {
        powerups.forEach({ addNewPowerup(for: $0) })
    }

    private func addNewPowerup(for spriteNode: SKSpriteNode) {
//        let randType = PowerupType.allCases.randomElement() ?? .playerHook
        let randType = PowerupType.netTrap

        let powerupEntity = PowerupEntity.createSpecializedEntity(for: randType)
        let powerupSprite = SpriteComponent(parent: powerupEntity)
        let collectableComponent = CollectableComponent(parent: powerupEntity,
                                                        position: spriteNode.position)
        let powerupComponent = PowerupComponent(parent: powerupEntity,
                                                type: randType)

        _ = spriteSystem.set(sprite: powerupSprite, to: spriteNode)
        _ = spriteSystem.setPhysicsBody(to: powerupSprite, of: .powerup,
                                        rectangleOf: powerupSprite.node.size)

        powerupEntity.addComponent(powerupSprite)
        powerupEntity.addComponent(collectableComponent)
        powerupEntity.addComponent(powerupComponent)
        self.powerups[spriteNode] = powerupEntity
        collectableSystem.set(for: powerupSprite, with: powerupComponent)
    }

    private func respawnPowerup(_ powerup: SKSpriteNode) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.powerupRespawnDelay) {
            let newPowerup = SKSpriteNode(texture: powerup.texture,
                                          color: .clear,
                                          size: powerup.size)
            newPowerup.position = powerup.position
            self.addNewPowerup(for: newPowerup)
            self.delegate?.addNotActivatedPowerup(newPowerup)
        }
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

    func addOtherPlayers(id: String, position: CGPoint, image: String) -> SKSpriteNode {
        let otherPlayer = PlayerEntity()

        let sprite = SpriteComponent(parent: otherPlayer)
        let spriteType = getOtherPlayerSpriteType()
        _ = spriteSystem.set(sprite: sprite, of: spriteType, with: image, at: position)
        _ = spriteSystem.setPhysicsBody(to: sprite, of: spriteType, rectangleOf: sprite.node.size)
        otherPlayer.addComponent(sprite)

        addPlayerComponents(to: otherPlayer)
        powerupEffectSystem.addPlayerSprite(playerId: id, sprite)

        otherPlayers[id] = otherPlayer

        finishingLineSystem.add(player: sprite)

        return sprite.node
    }

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
        guard let hook = player.getHookComponent() else {
            return
        }

        do {
            try hookSystem?.hookTo(hook: hook)

            guard let hookDelegateModel = createHookDelegateModel(from: hook) else {
                return
            }

            delegate?.playerDidHook(to: hookDelegateModel)
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

    private func playerUnhookAction(player: PlayerEntity) {
        guard let hook = player.getHookComponent() else {
            return
        }

        guard let hookDelegateModel = createHookDelegateModel(from: hook) else {
            return
        }

        do {
            try hookSystem?.unhookFrom(entity: player)
            delegate?.playerDidUnhook(from: hookDelegateModel)
        } catch HookSystemError.hookComponentDoesNotExist {
            print(HookSystemError.hookComponentDoesNotExist)
            return
        } catch {
            print("Unexpected error: \(error)")
            return
        }
    }

    private func createHookDelegateModel(from hook: HookComponent) -> HookDelegateModel? {
        guard let anchor = hook.anchor,
            let line = hook.line,
            let anchorLineJointPin = hook.anchorLineJointPin,
            let playerLineJointPin = hook.parentLineJointPin
            else {
                return nil
        }

        return HookDelegateModel(
            anchor: anchor,
            line: line,
            anchorLineJointPin: anchorLineJointPin,
            playerLineJointPin: playerLineJointPin
        )
    }

    // MARK: - Powerup Activation
    private func playerPowerupAction(with type: PowerupType,
                                     for player: PlayerEntity) {
        guard let playerSprite = player.getSpriteComponent() else {
            return
        }
        _ = powerupSystem.activate(powerupType: type, for: playerSprite)
    }

    // MARK: - Deadlock Detection

    private func checkDeadlock() {
        guard let deadlockSystem = deadLockSystem else {
            return
        }

        if gameState == .start && deadlockSystem.checkIfStuck() {
            delegate?.playerIsStuck()
        }
    }

    // MARK: - Game Setup

    private func setupTotalPlayers() {
        API.shared.lobby.get(lobbyId: self.gameId, completion: { lobby, error in
            guard error == nil else {
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
        })
    }

    // MARK: - General Game Methods

    private func startCountdown() {
        guard currentPlayer != nil else {
            return
        }

        if gameState != .waiting {
            return
        }

        let isAllPlayerInGame = totalNumberOfPlayers != 0 && totalNumberOfPlayers == otherPlayers.count + 1

        if isAllPlayerInGame {
            delegate?.startCountdown()
            gameState = .launching
        }
    }

    // MARK: - Multiplayer

    private func setupMultiplayer() {
//        subscribeToOtherPlayersState()
//        subscribeToHookAction()
//        subscribeToPowerupAction()
    }

    private func subscribeToOtherPlayersState() {
        API.shared.gameplay.subscribeToPlayersConnection(listener: { userConnection in
            if userConnection.state == .connected {
                self.setupPlayer(of: userConnection.uid)
            }

            // TODO: Setup Disconnected
        })
    }

    private func setupPlayer(of id: String) {
        API.shared.lobby.get(lobbyId: self.gameId, completion: { lobby, error in
            guard error == nil else {
                return
            }

            guard let costume = lobby?.costumesId[id] else {
                return
            }

            guard let initialPosition = self.cannon.getSpriteComponent()?.node.position else {
                return
            }

            let node = self.addOtherPlayers(id: id, position: initialPosition, image: costume.stringValue)

            // Delegate to GameScene
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
                self.playerUnhookAction(player: player)
            }
        })
    }

    private func subscribeToPowerupAction() {
        API.shared.gameplay.subscribeToPowerupAction(listener: { powerupAction in
            // TODO: Add implementation
        })
    }
}

extension GameEngine: PowerupSystemDelegate {
    func hasAddedTrap(sprite spriteComponent: SpriteComponent) {
        _ = spriteSystem.setPhysicsBody(to: spriteComponent,
                                        of: .netTrap,
                                        rectangleOf: spriteComponent.node.size)
        delegate?.addTrap(with: spriteComponent.node)
    }
}
