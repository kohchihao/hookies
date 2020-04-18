//
//  GameEngine.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//
// swiftlint:disable type_body_length
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
    private var cannonSystem: CannonSystem!
    private var finishingLineSystem: FinishingLineSystem!
    private var hookSystem: HookSystem?
    private var closestBoltSystem: ClosestBoltSystem?
    private var powerupSystem = PowerupSystem()
    private var deadlockSystem: DeadlockSystem?
    private var healthSystem: HealthSystem?
    private var userConnectionSystem: UserConnectionSystem?

    // MARK: - Entity

    private var currentPlayer: PlayerEntity?
    private var otherPlayers = [String: PlayerEntity]()
    private var platforms = [PlatformEntity]()
    private var bolts = [BoltEntity]()
    private var powerups = [SKSpriteNode: PowerupEntity]() // Key: Sprite of powerup, Value: Powerup Entity
    private var cannon = CannonEntity()
    private var finishingLine = FinishingLineEntity()

    init(
        gameId: String,
        cannon: SKSpriteNode,
        finishingLine: SKSpriteNode,
        bolts: [SKSpriteNode],
        powerups: [SKSpriteNode],
        platforms: [SKSpriteNode]
    ) {
        self.gameId = gameId

        let boltsSprite = initialiseBolts(bolts)
        initialisePowerups(powerups)
        powerupSystem.delegate = self

        let platformsSprite = initialisePlatforms(platforms)

        self.userConnectionSystem = UserConnectionSystem()
        self.hookSystem = HookSystem(bolts: boltsSprite)
        self.closestBoltSystem = ClosestBoltSystem(bolts: boltsSprite)

        let cannonSprite = createCannonSprite(from: cannon)
        self.cannonSystem = CannonSystem(cannon: cannonSprite)
        self.healthSystem = HealthSystem(platforms: platformsSprite, startLine: cannonSprite)

        let finishingLineSprite = createFinishingLineSprite(from: finishingLine)
        self.finishingLineSystem = FinishingLineSystem(finishingLine: finishingLineSprite)

        setupTotalPlayers()
        connectToGame()
        subscribeToGameConnection()
        setupMultiplayer()
        gameObjectMovementSystem.update()
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

        deadlockSystem = DeadlockSystem(sprite: sprite)
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
        cannonSystem.broadcastUpdate(gameId: gameId, playerId: currentPlayerId, player: sprite)
    }

    // MARK: - Start Game

    func startGame() {
        gameState = .start
    }

    // MARK: - Current Player Hook Action

    func applyHookActionToCurrentPlayer() {
        guard let currentPlayerId = currentPlayerId,
            let currentPlayer = currentPlayer else {
            return
        }

        guard let hook = currentPlayer.getHookComponent(),
             let sprite = currentPlayer.getSpriteComponent()
            else {
            return
        }

        guard let hookSystem = hookSystem else {
            return
        }

        guard let initialVelocity = sprite.node.physicsBody?.velocity else {
            return
        }

        hookSystem.broadcastUpdate(gameId: gameId, playerId: currentPlayerId, player: sprite, type: .activate)

        let hasHook = hookSystem.hook(from: currentPlayer)

        if !hasHook {
            return
        }

        guard let hookDelegateModel = createHookDelegateModel(from: hook) else {
            return
        }

        delegate?.playerDidHook(to: hookDelegateModel)
        hookSystem.applyInitialVelocity(sprite: sprite, velocity: initialVelocity)
        hookSystem.boostVelocity(to: currentPlayer)
    }

    func applyUnhookActionToCurrentPlayer() {
        guard let currentPlayerId = currentPlayerId,
            let currentPlayer = currentPlayer else {
            return
        }

        guard let hook = currentPlayer.getHookComponent(),
            let sprite = currentPlayer.getSpriteComponent()
            else {
            return
        }

        guard let hookDelegateModel = createHookDelegateModel(from: hook) else {
            return
        }

        guard let hookSystem = hookSystem else {
            return
        }

        hookSystem.broadcastUpdate(gameId: gameId, playerId: currentPlayerId, player: sprite, type: .deactivate)

        let hasUnhook = hookSystem.unhook(entity: currentPlayer)

        if !hasUnhook {
            return
        }

        delegate?.playerDidUnhook(from: hookDelegateModel)
    }

    func applyShortenActionToCurrentPlayer() {
        guard let currentPlayerId = currentPlayerId,
            let currentPlayer = currentPlayer else {
            return
        }

        guard let hook = currentPlayer.getHookComponent(),
            let sprite = currentPlayer.getSpriteComponent()
            else {
            return
        }

        guard let hookSystem = hookSystem else {
            return
        }

        guard !hookSystem.isShorterThanMin(for: currentPlayer) else {
            return
        }

        guard let initialVelocity = sprite.node.physicsBody?.velocity else {
            return
        }

        guard let unhookDelegateModel = createHookDelegateModel(from: hook) else {
            return
        }
        delegate?.playerDidUnhook(from: unhookDelegateModel)

        // TODO: Broadcast to socket

        let adjusted = hookSystem.adjustLength(from: currentPlayer, type: .shorten)

        if !adjusted {
            return
        }
        guard let hookDelegateModel = createHookDelegateModel(from: hook) else {
            return
        }
        delegate?.playerDidHook(to: hookDelegateModel)

        hookSystem.applyInitialVelocity(sprite: sprite, velocity: initialVelocity)
    }

    func applyLengthenActionToCurrentPlayer() {
        guard let currentPlayerId = currentPlayerId,
            let currentPlayer = currentPlayer else {
            return
        }

        guard let hook = currentPlayer.getHookComponent(),
            let sprite = currentPlayer.getSpriteComponent()
            else {
            return
        }

        guard let initialVelocity = sprite.node.physicsBody?.velocity else {
            return
        }

        guard let unhookDelegateModel = createHookDelegateModel(from: hook) else {
            return
        }
        delegate?.playerDidUnhook(from: unhookDelegateModel)

        guard let hookSystem = hookSystem else {
            return
        }

        // TODO: Broadcast to socket

        let adjusted = hookSystem.adjustLength(from: currentPlayer, type: .lengthen )

        if !adjusted {
            return
        }

        guard let hookDelegateModel = createHookDelegateModel(from: hook) else {
            return
        }
        delegate?.playerDidHook(to: hookDelegateModel)

        hookSystem.applyInitialVelocity(sprite: sprite, velocity: initialVelocity)
    }

    // MARK: - Current Player Powerup Action

    func currentPlayerPowerupAction(with type: PowerupType) {
        guard let currentPlayer = currentPlayer,
            let playerSprite = currentPlayer.get(SpriteComponent.self) else {
            return
        }
        powerupSystem.activate(powerupType: type, for: playerSprite)
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

        deadlockSystem?.broadcastUpdate(gameId: gameId, playerId: currentPlayerId, player: sprite)
        deadlockSystem?.resolveDeadlock()
    }

    // MARK: - Current Player Finsh Race

    func stopCurrentPlayer() {
        guard let currentPlayerId = currentPlayerId,
            let currentPlayer = currentPlayer else {
            return
        }

        guard let sprite = currentPlayer.getSpriteComponent() else {
            return
        }

        finishingLineSystem.broadcastUpdate(gameId: gameId, playerId: currentPlayerId, player: sprite)

        let hasStop = finishingLineSystem.stop(player: sprite)

        if !hasStop {
            return
        }

        delegate?.playerHasFinishRace()
    }

    // MARK: - Contact with Powerups

    func currentPlayerContactWith(powerup: SKSpriteNode) -> PowerupType? {
        guard let playerSprite = currentPlayer?.get(SpriteComponent.self),
            let powerupEntity = powerups[powerup],
            let powerupSprite = powerupEntity.getSpriteComponent(),
            let powerupIndex = powerups.index(forKey: powerupSprite.node),
            let powerupComponent = powerupEntity.get(PowerupComponent.self) else {
                return nil
        }

        powerups.remove(at: powerupIndex)
        spriteSystem.removePhysicsBody(to: powerupSprite)
        powerupSystem.collect(powerupComponent: powerupComponent, by: playerSprite)
        return powerupComponent.type
    }

    func currentPlayerContactWith(trap: SKSpriteNode) {
        guard let currentPlayer = currentPlayer,
            let currentPlayerSprite = currentPlayer.get(SpriteComponent.self) else {
                return
        }
        powerupSystem.activateNetTrap(at: trap.position, on: currentPlayerSprite)
    }

    // MARK: - Update

    func update(time: TimeInterval) {
        startCountdown()
        checkCurrentPlayerHealth()
        updateClosestBolt()
        checkDeadlock()
        finishingLineSystem.bringPlayersToStop()
        checkGameEnd()
    }

    // MARK: - Bolts

    private func initialiseBolts(_ bolts: [SKSpriteNode]) -> [SpriteComponent] {
        var boltsSprite = [SpriteComponent]()

        for bolt in bolts {
            let boltEntity = BoltEntity()

            let boltSprite = SpriteComponent(parent: boltEntity)
            _ = spriteSystem.set(sprite: boltSprite, to: bolt)
            _ = spriteSystem.setPhysicsBody(to: boltSprite, of: .bolt)

            let translate = NonPhysicsTranslateComponent(parent: boltEntity)

            if bolt.name == "bolt_movable" {
                bolt.physicsBody?.pinned = false

                let ending = CGPoint(x: bolt.position.x + 300, y: bolt.position.y)
                gameObjectMovementSystem.setTranslationLine(
                    to: boltSprite,
                    with: translate,
                    moveInfinitely: true,
                    speed: 50,
                    endingAt: ending)
            }

            boltEntity.addComponent(boltSprite)

            boltsSprite.append(boltSprite)
            self.bolts.append(boltEntity)
        }

        return boltsSprite
    }

    // MARK: - Power ups

    private func initialisePowerups(_ powerups: [SKSpriteNode]) {
        powerups.forEach({ addNewRandomPowerup(for: $0) })
    }

    private func addNewRandomPowerup(for spriteNode: SKSpriteNode) {
        let availablePowerups = [PowerupType.netTrap, PowerupType.shield]
//        let randType = PowerupType.allCases.randomElement() ?? .playerHook
        let randType = availablePowerups.randomElement() ?? PowerupType.shield
        addNewPowerup(with: randType, for: spriteNode)
    }

    private func addNewPowerup(with type: PowerupType,
                               for spriteNode: SKSpriteNode
    ) {
        let powerupEntity = PowerupEntity
            .createSpecializedEntity(for: type, at: spriteNode.position)

        guard let powerupSprite = powerupEntity.get(SpriteComponent.self),
            let powerupComponent = powerupEntity.get(PowerupComponent.self) else {
                return
        }
        _ = spriteSystem.set(sprite: powerupSprite, to: spriteNode)
        _ = spriteSystem.setPhysicsBody(to: powerupSprite, of: .powerup,
                                        rectangleOf: powerupSprite.node.size)
        powerups[spriteNode] = powerupEntity
        powerupSystem.add(powerup: powerupComponent)
    }

    private func respawnPowerup(_ powerup: SKSpriteNode) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.powerupRespawnDelay) {
            let newPowerup = SKSpriteNode(texture: powerup.texture,
                                          color: .clear,
                                          size: powerup.size)
            newPowerup.position = powerup.position
            self.addNewRandomPowerup(for: newPowerup)
            self.delegate?.addNotActivatedPowerup(newPowerup)
        }
    }

    // MARK: - Platform

    private func initialisePlatforms(_ platforms: [SKSpriteNode]) -> [SpriteComponent] {
        var platformsSprite = [SpriteComponent]()

        for platform in platforms {
            let platformEntity = PlatformEntity()

            let platformSprite = SpriteComponent(parent: platformEntity)
            _ = spriteSystem.set(sprite: platformSprite, to: platform)

            let translate = NonPhysicsTranslateComponent(parent: platformEntity)
            let rotate = RotateComponent(parent: platformEntity)
            if platform.name == "platform_movable" {
                platform.physicsBody?.pinned = false

                let ending = CGPoint(x: platform.position.x + 200, y: platform.position.y)
                gameObjectMovementSystem.setTranslationLine(
                    to: platformSprite,
                    with: translate,
                    moveInfinitely: true,
                    speed: 50,
                    endingAt: ending)
                gameObjectMovementSystem.setRotation(
                    to: platformSprite,
                    with: rotate,
                    withDuration: 10,
                    withAngle: 3.142)
            }

            platformEntity.addComponent(platformSprite)
            platformEntity.addComponent(translate)
            platformEntity.addComponent(rotate)

            platformsSprite.append(platformSprite)
            self.platforms.append(platformEntity)
        }

        return platformsSprite
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

    // MARK: - Health

    private func checkCurrentPlayerHealth() {
        guard let sprite = currentPlayer?.getSpriteComponent(), let healthSystem = healthSystem else {
            return
        }

        if !healthSystem.isPlayerAlive(for: sprite) {
            guard let currentPlayerId = currentPlayerId else {
                return
            }
            healthSystem.broadcastUpdate(gameId: gameId, playerId: currentPlayerId, player: sprite)
            _ = healthSystem.respawnPlayer(for: sprite)
        }
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

        otherPlayers[id] = otherPlayer

        finishingLineSystem.add(player: sprite)

        return sprite.node
    }

    private func addPlayerComponents(to player: PlayerEntity) {
        let hook = HookComponent(parent: player)

        player.addComponent(hook)
    }

    private func getOtherPlayerSpriteType() -> SpriteType {
        let numOtherPlayers = otherPlayers.count
        let typeIndex = numOtherPlayers + 1

        return SpriteType.otherPlayers[typeIndex]
    }

    private func createHookDelegateModel(from hook: HookComponent) -> HookDelegateModel? {
        guard let line = hook.line,
            let anchorLineJointPin = hook.anchorLineJointPin,
            let playerLineJointPin = hook.parentLineJointPin
            else {
                return nil
        }

        return HookDelegateModel(
            line: line,
            anchorLineJointPin: anchorLineJointPin,
            playerLineJointPin: playerLineJointPin
        )
    }

    // MARK: - Deadlock Detection

    private func checkDeadlock() {
        guard let deadlockSystem = deadlockSystem else {
            return
        }

        guard let currentPlayerSprite = currentPlayer?.getSpriteComponent() else {
            return
        }

        let hasPlayerFinishRace = finishingLineSystem.hasPlayerFinish(player: currentPlayerSprite)

        if gameState == .start && !hasPlayerFinishRace && deadlockSystem.checkIfStuck() {
            delegate?.playerIsStuck()
        }
    }

    // MARK: - General Game

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
        API.shared.gameplay.connect(roomId: gameId, completion: { otherPlayersId in
            for otherPlayerId in otherPlayersId {
                self.setupOtherPlayer(of: otherPlayerId)
            }
        })
    }

    private func subscribeToGameConnection() {
        API.shared.gameplay.subscribeToRoomConnection(roomId: gameId, listener: { connectionState in
            switch connectionState {
            case .connected:
                let isPlayerReconnecting = self.currentPlayerId != nil
                if isPlayerReconnecting {
                    self.delegate?.currentPlayerIsReconnected()
                }
            case .disconnected:
                self.delegate?.currentPlayerIsDisconnected()
            }
        })
    }

    private func updateClosestBolt() {
        guard let currentPlayerPosition = currentPlayer?.getSpriteComponent()?.node.position else {
            return
        }

        _ = closestBoltSystem?.findClosestBolt(to: currentPlayerPosition)
    }

    private func checkGameEnd() {
        guard let finishingLineSystem = finishingLineSystem else {
            return
        }

        guard gameState != .finish else {
            return
        }

        if finishingLineSystem.hasAllPlayersReachedFinishingLine() {
            API.shared.gameplay.close()
            gameState = .finish

            delegate?.gameHasFinish()
        }
    }

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
        subscribeToOtherPlayersState()
        subscribeToGenericPlayerEvent()
        subscribeToHookAction()
        subscribeToPowerupCollection()
        subscribeToPowerupEvent()
    }

    private func subscribeToPowerupCollection() {
        API.shared.gameplay.subscribeToPowerupCollection(listener: { collectionData in
            self.otherPlayerCollectedPowerup(powerupCollectionData: collectionData)
        })
    }

    private func subscribeToOtherPlayersState() {
        API.shared.gameplay.subscribeToPlayersConnection(listener: { userConnection in
            switch userConnection.state {
            case .connected:
                let isNewUser = self.otherPlayers[userConnection.uid] == nil

                if isNewUser {
                    self.setupOtherPlayer(of: userConnection.uid)
                } else {
                    self.reconnectOtherPlayer(of: userConnection.uid)
                }
            case .disconnected:
                self.disconnectOtherPlayer(of: userConnection.uid)
            }
        })
    }

    private func subscribeToGenericPlayerEvent() {
        API.shared.gameplay.subscribeToGenericPlayerEvent(listener: { genericPlayerEventData in
            switch genericPlayerEventData.type {
            case .shotFromCannon:
                self.launch(otherPlayer: genericPlayerEventData)
            case .jumpAction:
                self.applyJumpAction(to: genericPlayerEventData)
            case .playerDied:
                self.respawn(otherPlayer: genericPlayerEventData)
            case .reachedFinishedLine:
                self.stop(otherPlayer: genericPlayerEventData)
            case .hook:
                print("hook")
            case .unhook:
                print("unhook")
            case .lengthenRope:
                print("lengthenRope")
            case .shortenRope:
                print("shortenRope")
            }
        })
    }

    private func subscribeToHookAction() {
        API.shared.gameplay.subscribeToHookAction(listener: { hookActionData in

            switch hookActionData.actionType {
            case .activate:
                self.applyHookAction(on: hookActionData)
            case .deactivate:
                self.applyUnhookAction(on: hookActionData)
            }
        })
    }

    private func subscribeToPowerupEvent() {
        API.shared.gameplay.subscribeToPowerupEvent(listener: { powerupEvent in
            let playerId = powerupEvent.playerData.playerId
            guard let player = self.otherPlayers[playerId],
                let playerSprite = player.get(SpriteComponent.self) else {
                    return
            }

            playerSprite.node.position = CGPoint(vector: powerupEvent.playerData.position)
            switch powerupEvent.eventType {
            case .activate:
                self.powerupSystem.activate(powerupType: powerupEvent.type,
                                            for: playerSprite)
            case .netTrapped:
                let eventPos = CGPoint(vector: powerupEvent.eventPos)
                self.powerupSystem.activateNetTrap(at: eventPos, on: playerSprite)
            case .deactivate:
                return
            }
        })
    }

    private func otherPlayerCollectedPowerup(powerupCollectionData: PowerupCollectionData) {
        let positionOfCollection = CGPoint(vector: powerupCollectionData.powerupPos)
        let ownerId = powerupCollectionData.playerData.playerId

        guard let powerupSprite = findPowerupSprite(at: positionOfCollection),
            let powerupIndex = powerups.index(forKey: powerupSprite) else {
                return
        }

        powerups.remove(at: powerupIndex)
        addNewPowerup(with: powerupCollectionData.type, for: powerupSprite)

        guard let powerupEntity = powerups[powerupSprite],
            let powerupSpriteComponent = powerupEntity.get(SpriteComponent.self) else {
                return
        }

        guard let playerEntity = otherPlayers[ownerId],
            let player = playerEntity.get(SpriteComponent.self),
            let powerupComponent = powerupEntity.get(PowerupComponent.self),
            let updatedPowerupIndex = powerups.index(forKey: powerupSprite) else {
            return
        }

        spriteSystem.removePhysicsBody(to: powerupSpriteComponent)
        powerups.remove(at: updatedPowerupIndex)
        powerupSystem.collect(powerupComponent: powerupComponent, by: player)
    }

    private func findPowerupSprite(at point: CGPoint) -> SKSpriteNode? {
        for powerupSprite in powerups.keys {
            if powerupSprite.frame.contains(point) {
                return powerupSprite
            }
        }
        return nil
    }

    private func setupOtherPlayer(of id: String) {
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

            self.delegate?.otherPlayerIsConnected(otherPlayer: node)
        })
    }

    private func reconnectOtherPlayer(of id: String) {
        guard let otherPlayer = otherPlayers[id] else {
            return
        }

        guard let sprite = otherPlayer.getSpriteComponent() else {
            return
        }

        finishingLineSystem.add(player: sprite)
        userConnectionSystem?.reconnect(sprite: sprite)
    }

    private func disconnectOtherPlayer(of id: String) {
        guard let otherPlayer = otherPlayers[id] else {
            return
        }

        guard let sprite = otherPlayer.getSpriteComponent() else {
            return
        }

        finishingLineSystem.remove(player: sprite)
        userConnectionSystem?.disconnect(sprite: sprite)
    }

    private func launch(otherPlayer: GenericPlayerEventData) {
        guard let otherPlayerEntity = otherPlayers[otherPlayer.playerData.playerId] else {
            return
        }

        guard let sprite = otherPlayerEntity.getSpriteComponent() else {
            return
        }

        guard let velocity = otherPlayer.playerData.velocity else {
            return
        }

        cannonSystem.launch(otherPlayer: sprite, with: CGVector(vector: velocity))
    }

    private func applyJumpAction(to otherPlayer: GenericPlayerEventData) {
        guard let otherPlayerEntity = otherPlayers[otherPlayer.playerData.playerId] else {
            return
        }

        guard let sprite = otherPlayerEntity.getSpriteComponent() else {
            return
        }

        guard let velocity = otherPlayer.playerData.velocity else {
            return
        }

        deadlockSystem?.resolveDeadlock(
            for: sprite,
            at: CGPoint(vector: otherPlayer.playerData.position),
            with: CGVector(vector: velocity)
        )
    }

    private func respawn(otherPlayer: GenericPlayerEventData) {
        guard let sprite = otherPlayers[otherPlayer.playerData.playerId]?.getSpriteComponent() else {
            return
        }

        _ = healthSystem?.respawnPlayer(for: sprite, at: CGPoint(vector: otherPlayer.playerData.position))
    }

    private func stop(otherPlayer: GenericPlayerEventData) {
        guard let otherPlayerEntity = otherPlayers[otherPlayer.playerData.playerId] else {
            return
        }

        let position = CGPoint(vector: otherPlayer.playerData.position)

        guard let sprite = otherPlayerEntity.getSpriteComponent() else {
            return
        }

        guard let velocity = otherPlayer.playerData.velocity else {
            return
        }

        _ = finishingLineSystem.stop(player: sprite, at: position, with: CGVector(vector: velocity))
    }

    private func applyHookAction(on hook: HookActionData) {
        guard let otherPlayer = otherPlayers[hook.playerData.playerId] else {
            return
        }

        guard let hookComponent = otherPlayer.getHookComponent(),
            let spriteComponent = otherPlayer.getSpriteComponent()
            else {
            return
        }

        guard let velocity = hook.playerData.velocity else {
            return
        }

        guard let hookSystem = hookSystem else {
            return
        }

        let hasHook = hookSystem.hook(
            from: otherPlayer,
            at: CGPoint(vector: hook.playerData.position),
            with: CGVector(vector: velocity)
        )

        if !hasHook {
            return
        }

        guard let hookDelegateModel = createHookDelegateModel(from: hookComponent) else {
            return
        }

        delegate?.playerDidHook(to: hookDelegateModel)
        hookSystem.applyInitialVelocity(sprite: spriteComponent, velocity: CGVector(vector: velocity))
        hookSystem.boostVelocity(to: otherPlayer)
    }

    private func applyUnhookAction(on hook: HookActionData) {
        guard let otherPlayer = otherPlayers[hook.playerData.playerId] else {
            return
        }

        guard let hookComponent = otherPlayer.getHookComponent() else {
            return
        }

        guard let hookDelegateModel = createHookDelegateModel(from: hookComponent) else {
            return
        }

        guard let hookSystem = hookSystem else {
            return
        }

        let hasUnhook = hookSystem.unhook(entity: otherPlayer)

        if !hasUnhook {
            return
        }

        delegate?.playerDidUnhook(from: hookDelegateModel)
    }
}

extension GameEngine: PowerupSystemDelegate {
    func hasAddedTrap(sprite spriteComponent: SpriteComponent) {
        _ = spriteSystem.setPhysicsBody(to: spriteComponent, of: .netTrap,
                                        rectangleOf: spriteComponent.node.size)
        delegate?.addTrap(with: spriteComponent.node)
    }
}
