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
    private var powerupSystem = PowerupSystem()
    private var deadlockSystem: DeadlockSystem?
    private var healthSystem: HealthSystem?
    private var userConnectionSystem: UserConnectionSystem?
    private var startSystem = StartSystem()

    // MARK: - Entity

    private var currentPlayer: PlayerEntity?
    private var otherPlayers = [String: PlayerEntity]()
    private var platforms = [PlatformEntity]()
    private var bolts = [BoltEntity]()
    private var powerups = [SKSpriteNode: PowerupEntity]() // Key: Sprite of powerup, Value: Powerup Entity
    private var cannon = CannonEntity()
    private var finishingLine = FinishingLineEntity()
    private var netTraps = [SKSpriteNode: NetTrapPowerupEntity]()

    private var startPosition: CGPoint

    init(
        cannon: GameObject,
        finishingLine: GameObject,
        bolts: [GameObject],
        powerups: [GameObject],
        platforms: [GameObject]
    ) {
        startPosition = cannon.node.position

        let boltsSprite = initialiseBolts(bolts)
        let platformsSprite = initialisePlatforms(platforms)
        initialisePowerups(powerups)

        userConnectionSystem = UserConnectionSystem()
        hookSystem = HookSystem(bolts: boltsSprite)
        closestBoltSystem = ClosestBoltSystem(bolts: boltsSprite)
        healthSystem = HealthSystem(platforms: platformsSprite, startPosition: startPosition)

        initialiseCannon(cannon)
        initialiseFinishingLine(finishingLine)

        initialiseDelegates()
        gameObjectMovementSystem.update()
    }

    private func initialiseDelegates() {
        self.startSystem.delegate = self
        self.hookSystem?.delegate = self
        self.userConnectionSystem?.delegate = self
        self.finishingLineSystem.delegate = self
        self.powerupSystem.delegate = self
    }

    // MARK: - Add Players

    func addPlayers(_ players: [Player]) {
        initialisePlayers(players)
        startSystem.getReady()
    }

    // MARK: - Launch Current Player

    func launchCurrentPlayer(with velocity: CGVector) {
        guard let sprite = currentPlayer?.get(SpriteComponent.self) else {
            return
        }

        cannonSystem.launch(player: sprite, with: velocity)
    }

    // MARK: - Current Player Hook Action

    func applyHookActionToCurrentPlayer() {
        guard let currentPlayer = currentPlayer else {
            return
        }

        _ = hookSystem?.hook(from: currentPlayer)
    }

    func applyUnhookActionToCurrentPlayer() {
        guard let currentPlayer = currentPlayer else {
            return
        }

        _ = hookSystem?.unhook(entity: currentPlayer)
    }

    // MARK: - Current Player Adjust Action

    func applyShortenActionToCurrentPlayer() {
        guard let currentPlayer = currentPlayer else {
            return
        }

        guard let hookSystem = hookSystem else {
            return
        }

        guard !hookSystem.isShorterThanMin(for: currentPlayer) else {
            return
        }

        _ = hookSystem.adjustLength(from: currentPlayer, type: .shorten)
    }

    func applyLengthenActionToCurrentPlayer() {
        guard let currentPlayer = currentPlayer else {
            return
        }

        _ = hookSystem?.adjustLength(from: currentPlayer, type: .lengthen)
    }

    // MARK: - Current Player Powerup Action

    func currentPlayerPowerupAction(with type: PowerupType) {
        guard let playerId = currentPlayerId,
            let currentPlayer = currentPlayer else {
            return
        }
        playerPowerupAction(with: type, for: currentPlayer, playerId: playerId)
    }

    // MARK: - Current Player Jump Action

    func currentPlayerJumpAction() {
        deadlockSystem?.resolveDeadlock()
    }

    // MARK: - Current Player Finsh Race

    func stopCurrentPlayer() {
        guard let sprite = currentPlayer?.get(SpriteComponent.self) else {
            return
        }

        let hasStop = finishingLineSystem.stop(player: sprite)

        if !hasStop {
            return
        }

        delegate?.playerHasFinishRace()
    }

    // MARK: - Contact with Collectables

    func currentPlayerContactWith(powerup: SKSpriteNode) -> PowerupType? {
        guard let playerId = currentPlayerId,
            let currentPlayer = currentPlayer,
            let playerSprite = currentPlayer.get(SpriteComponent.self),
            let powerupEntity = powerups[powerup],
            let powerupSprite = powerupEntity.getSpriteComponent(),
            let powerupIndex = powerups.index(forKey: powerupSprite.node) else {
                return nil
        }

        guard let powerupComponent = collectableSystem.collect(powerup: powerupEntity, playerId: playerId) else {
            return nil
        }

        spriteSystem.removePhysicsBody(to: powerupSprite)
        powerups.remove(at: powerupIndex)
        powerupSystem.add(player: currentPlayer, with: powerupComponent)

        let playerNode = playerSprite.node
        let powerupPosition = Vector(point: powerupSprite.node.position)
        let collectionData = PowerupCollectionData(playerId: playerId,
                                                   node: playerNode,
                                                   powerupPosition: powerupPosition,
                                                   powerupType: powerupComponent.type)
        API.shared.gameplay.broadcastPowerupCollection(powerupCollection: collectionData)
        return powerupComponent.type
    }

    // MARK: - Contact with Trap Powerup

    func findTrapAt(point: CGPoint) -> SKSpriteNode? {
        for trap in netTraps.keys where trap.frame.contains(point) {
            return trap
        }
        return nil
    }

    func playerContactWith(trap: SKSpriteNode, playerId: String) {
        guard let netTrap = netTraps[trap],
            let contactedPlayer = playerId == currentPlayerId ?
                currentPlayer : otherPlayers[playerId],
            let playerSprite = contactedPlayer.get(SpriteComponent.self),
            let powerupComponent = netTrap.get(PowerupComponent.self) else {
                return
        }
        if let ownerId = powerupComponent.ownerId {
            if playerId == ownerId {
                return
            }
        }

        let effects = netTrap.getMultiple(PowerupEffectComponent.self)
        for effect in effects {
            powerupSystem.apply(effect: effect, by: playerSprite)
        }

        if currentPlayer != nil && contactedPlayer === currentPlayer! {
            let eventPosition = Vector(point: trap.position)
//            powerupSystem.broadcastUpdate(gameId: gameId,
//                                          playerId: playerId,
//                                          player: contactedPlayer,
//                                          powerupType: powerupComponent.type,
//                                          eventType: .netTrapped,
//                                          eventPos: eventPosition)
        }
    }

    // MARK: - Update

    func update(time: TimeInterval) {
        checkCurrentPlayerHealth()
        updateClosestBolt()
        checkDeadlock()
        finishingLineSystem.bringPlayersToStop()
    }

    // MARK: - Bolts

    private func initialiseBolts(_ bolts: [GameObject]) -> [SpriteComponent] {
        var boltsSprite = [SpriteComponent]()

        for bolt in bolts {
            guard bolt.type == .bolt || bolt.type == .boltMovable else {
                fatalError("Failed to initialise bolt")
            }

            let boltEntity = BoltEntity()

            guard let boltSprite = boltEntity.get(SpriteComponent.self),
                let translate = boltEntity.get(NonPhysicsTranslateComponent.self) else {
                    print("GameEngine - initialisebolt: Components are nil")
                    return boltsSprite
            }

            _ = spriteSystem.set(sprite: boltSprite, to: bolt.node)
            _ = spriteSystem.setPhysicsBody(to: boltSprite, of: .bolt)

            if bolt.node.name == GameObjectType.boltMovable.rawValue {
                bolt.node.physicsBody?.pinned = false

                let ending = CGPoint(x: bolt.node.position.x + 300, y: bolt.node.position.y)
                gameObjectMovementSystem.setTranslationLine(
                    to: boltSprite,
                    with: translate,
                    moveInfinitely: true,
                    speed: 50,
                    endingAt: ending)
            }

            boltsSprite.append(boltSprite)
            self.bolts.append(boltEntity)
        }

        return boltsSprite
    }

    // MARK: - Power ups

    private func initialisePowerups(_ powerups: [GameObject]) {
        powerups.forEach({ addNewRandomPowerup(for: $0.node) })
    }

    private func addNewRandomPowerup(for spriteNode: SKSpriteNode) {
        let availablePowerups = [PowerupType.netTrap, PowerupType.shield]
//        let randType = PowerupType.allCases.randomElement() ?? .playerHook
        let randType = availablePowerups.randomElement() ?? PowerupType.shield
        addNewPowerup(with: randType, for: spriteNode)
    }

    private func addNewPowerup(with type: PowerupType, for spriteNode: SKSpriteNode) {
        let powerupEntity = PowerupEntity.createSpecializedEntity(for: type)
        let powerupSprite = SpriteComponent(parent: powerupEntity)
        let collectableComponent = CollectableComponent(parent: powerupEntity,
                                                        position: spriteNode.position)
        let powerupComponent = PowerupComponent(parent: powerupEntity,
                                                type: type)

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
            self.addNewRandomPowerup(for: newPowerup)
            self.delegate?.addNotActivatedPowerup(newPowerup)
        }
    }

    // MARK: - Platform

    private func initialisePlatforms(_ platforms: [GameObject]) -> [SpriteComponent] {
        var platformsSprite = [SpriteComponent]()

        for platform in platforms {
            guard platform.type == .platform || platform.type == .platformMovable else {
                fatalError("Failed to initialise platform")
            }

            let platformEntity = PlatformEntity()

            guard let platformSprite = platformEntity.get(SpriteComponent.self),
                let translate = platformEntity.get(NonPhysicsTranslateComponent.self),
                let rotate = platformEntity.get(RotateComponent.self)
                else {
                    print("GameEngine - initialisePlatforms: Components are nil")
                    return platformsSprite
            }

            _ = spriteSystem.set(sprite: platformSprite, to: platform.node)

            if platform.node.name == GameObjectType.platformMovable.rawValue {
                platform.node.physicsBody?.pinned = false

                let ending = CGPoint(x: platform.node.position.x + 200, y: platform.node.position.y)
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

            platformsSprite.append(platformSprite)
            self.platforms.append(platformEntity)
        }

        return platformsSprite
    }

    // MARK: - Cannon

    private func initialiseCannon(_ cannon: GameObject) {
        guard cannon.type == .cannon else {
            fatalError("Failed to initalise cannon")
        }

        guard let sprite = self.cannon.get(SpriteComponent.self) else {
            return
        }
        _ = spriteSystem.set(sprite: sprite, to: cannon.node)

        self.cannonSystem = CannonSystem(cannon: sprite)
    }

    // MARK: - Finishing Line

    private func initialiseFinishingLine(_ finishingLine: GameObject) {
        guard finishingLine.type == .finishingLine else {
            fatalError("Failed to initalise finishing line")
        }

        guard let sprite = self.finishingLine.get(SpriteComponent.self) else {
            return
        }
        _ = spriteSystem.set(sprite: sprite, to: finishingLine.node)
        _ = spriteSystem.setPhysicsBody(to: sprite, of: .finishingLine, rectangleOf: sprite.node.size)

        self.finishingLineSystem = FinishingLineSystem(finishingLine: sprite)
    }

    // MARK: - Health

    private func checkCurrentPlayerHealth() {
        guard let sprite = currentPlayer?.get(SpriteComponent.self), let healthSystem = healthSystem else {
            return
        }

        if !healthSystem.isPlayerAlive(for: sprite) {
            _ = healthSystem.respawnPlayer(for: sprite)
        }
    }

    // MARK: - Initialise Players

    private func initialisePlayers(_ players: [Player]) {
        for player in players {
            if player.isCurrentPlayer {
                setCurrentPlayer(player)
            } else {
                setOtherPlayer(player)
            }
        }
    }

    private func setCurrentPlayer(_ player: Player) {
        let playerEntity = PlayerEntity()

        guard let sprite = playerEntity.get(SpriteComponent.self),
            let hook = playerEntity.get(HookComponent.self)
            else {
            return
        }
        _ = spriteSystem.set(sprite: sprite, of: .player1, with: player.costumeType.stringValue, at: startPosition)
        _ = spriteSystem.setPhysicsBody(to: sprite, of: .player1, rectangleOf: sprite.node.size)

        currentPlayer = playerEntity

        deadlockSystem = DeadlockSystem(sprite: sprite, hook: hook)
        finishingLineSystem.add(player: sprite)
        startSystem.add(player: player, with: sprite)

        delegate?.addCurrentPlayer(with: sprite.node)
    }

    private func setOtherPlayer(_ player: Player) {
        let playerEntity = PlayerEntity()

        guard let sprite = playerEntity.get(SpriteComponent.self) else {
            return
        }
        let spriteType = getOtherPlayerSpriteType()
        _ = spriteSystem.set(sprite: sprite, of: spriteType, with: player.costumeType.stringValue, at: startPosition)
        _ = spriteSystem.setPhysicsBody(to: sprite, of: spriteType, rectangleOf: sprite.node.size)

        finishingLineSystem.add(player: sprite)
        startSystem.add(player: player, with: sprite)

        delegate?.addPlayer(with: sprite.node)
    }

    private func getOtherPlayerSpriteType() -> SpriteType {
        let numOtherPlayers = otherPlayers.count
        let typeIndex = numOtherPlayers + 1

        return SpriteType.otherPlayers[typeIndex]
    }

    // MARK: - Powerup Activation

    private func playerPowerupAction(with type: PowerupType,
                                     for player: PlayerEntity,
                                     playerId: String
    ) {
        guard let playerSprite = player.getSpriteComponent() else {
            return
        }
        powerupSystem.activate(powerupType: type, for: playerSprite)
//        powerupSystem.broadcastUpdate(gameId: gameId, playerId: playerId,
//                                      player: player,
//                                      powerupType: type,
//                                      eventType: .activate)
    }

    // MARK: - Deadlock Detection

    private func checkDeadlock() {
        guard let deadlockSystem = deadlockSystem else {
            return
        }

        guard let currentPlayerSprite = currentPlayer?.get(SpriteComponent.self) else {
            return
        }

        let hasPlayerFinishRace = finishingLineSystem.hasPlayerFinish(player: currentPlayerSprite)

        if gameState == .start && !hasPlayerFinishRace && deadlockSystem.checkIfStuck() {
            delegate?.playerIsStuck()
        }
    }

    // MARK: - General Game

    private func updateClosestBolt() {
        guard let currentPlayerPosition = currentPlayer?.get(SpriteComponent.self)?.node.position else {
            return
        }

        _ = closestBoltSystem?.findClosestBolt(to: currentPlayerPosition)
    }

    // MARK: - Multiplayer

    // TODO: To Remove
    private func subscribeToPowerupCollection() {
        API.shared.gameplay.subscribeToPowerupCollection(listener: { collectionData in
            self.otherPlayerCollectedPowerup(powerupCollectionData: collectionData)
        })
    }

    // TODO: To Remove
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
                print("activate powerup other", powerupEvent.type)
                self.powerupSystem.activate(powerupType: powerupEvent.type,
                                            for: playerSprite)
            case .netTrapped:
                let eventPos = CGPoint(vector: powerupEvent.eventPos)
                guard let trap = self.findTrapAt(point: eventPos) else {
                    return
                }
                self.playerContactWith(trap: trap, playerId: playerId)
                return
            case .deactivate:
                return
            }
        })
    }

    // TODO: To Remove
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

        guard let player = otherPlayers[ownerId],
            let powerupComponent = collectableSystem.collect(powerup: powerupEntity,
                                                             playerId: ownerId),
            let updatedPowerupIndex = powerups.index(forKey: powerupSprite) else {
            return
        }

        spriteSystem.removePhysicsBody(to: powerupSpriteComponent)
        powerups.remove(at: updatedPowerupIndex)
        powerupSystem.add(player: player, with: powerupComponent)
    }

    // TODO: To Remove
    private func findPowerupSprite(at point: CGPoint) -> SKSpriteNode? {
        for powerupSprite in powerups.keys {
            if powerupSprite.frame.contains(point) {
                return powerupSprite
            }
        }
        return nil
    }
}

// MARK: - StartSystemDelegate

extension GameEngine: StartSystemDelegate {
    func isReadyToStart() {
        startCountdown()
    }

    func startGame() {
        gameState = .start
    }

    private func startCountdown() {
        guard currentPlayer != nil else {
            return
        }

        guard gameState == .waiting else {
            return
        }

        delegate?.startCountdown()
        gameState = .launching
    }
}

// MARK: - HookSystemDelegate

extension GameEngine: HookSystemDelegate {
    func adjustHookActionApplied(sprite: SpriteComponent, velocity: CGVector, hook: HookComponent) {
        guard let hookDelegateModel = createHookDelegateModel(from: hook) else {
            return
        }

        delegate?.playerDidHook(to: hookDelegateModel)
        hookSystem?.applyInitialVelocity(sprite: sprite, velocity: velocity)
    }

    func hookActionApplied(sprite: SpriteComponent, velocity: CGVector, hook: HookComponent) {
        guard let hookDelegateModel = createHookDelegateModel(from: hook) else {
            return
        }

        delegate?.playerDidHook(to: hookDelegateModel)
        hookSystem?.applyInitialVelocity(sprite: sprite, velocity: velocity)
        hookSystem?.boostVelocity(to: sprite.parent)
    }

    func unhookActionApplied(hook: HookComponent) {
        guard let hookDelegateModel = createHookDelegateModel(from: hook) else {
            return
        }

        delegate?.playerDidUnhook(from: hookDelegateModel)
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
}

// MARK: - UserConnectionSystemDelegate

extension GameEngine: UserConnectionSystemDelegate {
    func userConnected() {
        delegate?.currentPlayerIsReconnected()
    }

    func userDisconnected() {
        delegate?.currentPlayerIsDisconnected()
    }
}

// MARK: - FinishingLineSystemDelegate

extension GameEngine: FinishingLineSystemDelegate {
    func gameEnded(rankings: [SpriteComponent]) {
        delegate?.gameHasFinish()
    }
}

// MARK: - PowerupSystemDelegate

extension GameEngine: PowerupSystemDelegate {
    func hasAddedTrap(sprite spriteComponent: SpriteComponent, netTrap: NetTrapPowerupEntity) {
        _ = spriteSystem.setPhysicsBody(to: spriteComponent,
                                        of: .netTrap,
                                        rectangleOf: spriteComponent.node.size)
        netTraps[spriteComponent.node] = netTrap
        delegate?.addTrap(with: spriteComponent.node)
    }
}
