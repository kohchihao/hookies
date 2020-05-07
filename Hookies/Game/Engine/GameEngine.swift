//
//  GameEngine.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//
import SpriteKit

/// Handles the coordination between the different game logic
class GameEngine {
    private var gameState: GameState = .waiting
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
    private var startSystem = StartSystem()
    private var endSystem: EndSystem?
    private var botSystem: BotSystem?

    // MARK: - Powerup Effect Systems

    private var playerHookEffectSystem = PlayerHookEffectSystem()
    private var shieldEffectSystem = ShieldEffectSystem()
    private var placementEffectSystem = PlacementEffectSystem()
    private var movementEffectSystem = MovementEffectSystem()
    private var cutRopeEffectSystem = CutRopeEffectSystem()
    private var stealEffectSystem = StealEffectSystem()

    // MARK: - Entity

    private var currentPlayer: PlayerEntity?
    private var numOtherPlayers = 0
    private var localPlayers: [PlayerEntity] = []
    private var platforms = [PlatformEntity]()
    private var bolts = [BoltEntity]()
    private var collectablePowerups = [PowerupEntity]()
    private var ownedPowerups = [PowerupEntity]()
    private var cannon = CannonEntity()
    private var finishingLine = FinishingLineEntity()

    private var startPosition: CGPoint

    init(
        cannon: GameObject,
        finishingLine: GameObject,
        bolts: [GameObject],
        powerups: [GameObject],
        platforms: [GameObject],
        hasBot: Bool
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

        if hasBot {
            self.botSystem = BotSystem()
        }

        initialiseDelegates()
        gameObjectMovementSystem.update()
        Logger.log.traceableFunctionName = true
    }

    private func initialiseDelegates() {
        startSystem.delegate = self
        hookSystem?.delegate = self
        userConnectionSystem?.delegate = self
        powerupSystem.delegate = self
        playerHookEffectSystem.delegate = self
        placementEffectSystem.delegate = self
        movementEffectSystem.delegate = self
        cutRopeEffectSystem.delegate = self
        stealEffectSystem.delegate = self
    }

    // MARK: - Add Players
    /// Add all the players to the game
    /// - Parameters:
    ///     - players: A list of Player
    func addPlayers(_ players: [Player]) {
        initialisePlayers(players)
        startSystem.getReady()

        endSystem = EndSystem(totalPlayers: players.count)
        endSystem?.delegate = self
    }

    // MARK: - Launch Current Player
    /// Launches all the players on the current device with a given velocity
    /// - Parameters:
    ///     - velocity: The velocity to launch the player
    func launchLocalPlayers(with velocity: CGVector) {
        for player in localPlayers {
            guard let sprite = player.get(SpriteComponent.self) else {
                return
            }
            cannonSystem.launch(player: sprite, with: velocity)
        }
    }

    // MARK: - Current Player Hook Action
    /// Handles the logic to the hook action of the current player
    func applyHookActionToCurrentPlayer() {
        guard let currentPlayer = currentPlayer else {
            return
        }

        _ = hookSystem?.hook(from: currentPlayer)
    }

    /// Handles the logic to the unhook action of the current player
    func applyUnhookActionToCurrentPlayer() {
        guard let currentPlayer = currentPlayer else {
            return
        }

        _ = hookSystem?.unhook(entity: currentPlayer)
    }

    // MARK: - Current Player Adjust Action
    /// Handles the logic to the shorten rope  action of the current player
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

    /// Handles the logic to the lengthen rope  action of the current player
    func applyLengthenActionToCurrentPlayer() {
        guard let currentPlayer = currentPlayer else {
            return
        }

        _ = hookSystem?.adjustLength(from: currentPlayer, type: .lengthen)
    }

    // MARK: - Current Player Powerup Action
    /// Activiates the powerup of the current player.
    func currentPlayerPowerupAction(with type: PowerupType) {
        guard let currentPlayer = currentPlayer,
            let playerSprite = currentPlayer.get(SpriteComponent.self) else {
            return
        }
        powerupSystem.activatePowerup(for: playerSprite)
    }

    // MARK: - Current Player Jump Action
    /// Handles the logic to the jump  action of the current player
    func currentPlayerJumpAction() {
        deadlockSystem?.resolveDeadlock()
    }

    // MARK: - Local Player Finish Race
    /// Stops all the players on the current device of the given node
    /// - Parameters:
    ///     - playerNode: The node of the local player to stop
    func stopLocalPlayer(playerNode: SKSpriteNode) {
        for player in localPlayers {
            guard let playerSprite = player.get(SpriteComponent.self) else {
                continue
            }
            if playerSprite.node == playerNode {
                guard let currentPlayer = currentPlayer else {
                    return
                }
                if player === currentPlayer {
                    stopCurrentPlayer()
                    break
                } else {
                    botSystem?.stopBot(botSprite: playerSprite)
                    break
                }
            }
        }
    }

    // MARK: - Contact with Powerups
    /// Handles the logic of collecting of powerups for current player
    func currentPlayerContactWith(powerup: SKSpriteNode) {
        guard let playerSprite = currentPlayer?.get(SpriteComponent.self) else {
            return
        }
        powerupSystem.collect(powerupNode: powerup, by: playerSprite)
    }

    /// Handles the contact logic between a player and a trap in the game
    /// - Parameters:
    ///     - playerNode: The player's node that has contact with the trap
    ///     - trap: The trap's node that has contact with the player
    func contactBetween(playerNode: SKSpriteNode, trap: SKSpriteNode) {
        for player in localPlayers {
            guard let playerSprite = player.get(SpriteComponent.self) else {
                continue
            }
            if playerSprite.node == playerNode {
                powerupSystem.activateTrap(at: trap.position, on: playerSprite)
                break
            }
        }
    }

    // MARK: - Update
    /// Handles all the elements that need to be checked / updated at every time interval
    /// - Parameters:
    ///     - time: The time interval
    func update(time: TimeInterval) {
        checkLocalPlayerHealth()
        updateClosestBolt()
        updateEffectSystems()
        checkDeadlock()
        finishingLineSystem.bringPlayersToStop()
    }

    private func updateEffectSystems() {
        playerHookEffectSystem.update(entities: ownedPowerups)
        shieldEffectSystem.update(entities: ownedPowerups)
        placementEffectSystem.update(entities: ownedPowerups)
        movementEffectSystem.update(entities: ownedPowerups)
        cutRopeEffectSystem.update(entities: ownedPowerups)
        stealEffectSystem.update(entities: ownedPowerups)
        powerupSystem.removeActivatedPowerups()
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
                    Logger.log.show(details: "Components are nil", logType: .error)
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
        let powerup = PowerupEntity.createWithRandomType()
        guard let powerupComponent = powerup.get(PowerupComponent.self),
            let powerupSprite = powerup.get(SpriteComponent.self) else {
            return
        }

        _ = spriteSystem.set(sprite: powerupSprite, to: spriteNode)
        _ = spriteSystem.setPhysicsBody(to: powerupSprite, of: .powerup,
                                        rectangleOf: powerupSprite.node.size)

        collectablePowerups.append(powerup)
        powerupSystem.addCollectable(powerup: powerupComponent)
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
                    Logger.log.show(details: "Components are nil", logType: .error)
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

    private func checkLocalPlayerHealth() {
        for player in localPlayers {
            guard let sprite = player.get(SpriteComponent.self), let healthSystem = healthSystem else {
                continue
            }

            if !healthSystem.isPlayerAlive(for: sprite) {
                _ = healthSystem.respawnPlayer(for: sprite)
            }
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
        localPlayers.append(playerEntity)

        deadlockSystem = DeadlockSystem(sprite: sprite, hook: hook)
        finishingLineSystem.add(player: sprite)
        startSystem.add(player: player, with: sprite)
        hookSystem?.add(player: sprite)
        powerupSystem.add(player: sprite)
        playerHookEffectSystem.add(player: sprite)
        movementEffectSystem.add(player: sprite)
        cutRopeEffectSystem.add(player: sprite)
        stealEffectSystem.add(player: sprite)

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

        numOtherPlayers += 1

        finishingLineSystem.add(player: sprite)
        startSystem.add(player: player, with: sprite)
        hookSystem?.add(player: sprite)
        powerupSystem.add(player: sprite)
        playerHookEffectSystem.add(player: sprite)
        movementEffectSystem.add(player: sprite)
        cutRopeEffectSystem.add(player: sprite)
        stealEffectSystem.add(player: sprite)

        if player.playerType == .bot {
            if let botType = player.botType {
                addBot(sprite: sprite, botType: botType)
                localPlayers.append(playerEntity)
            }
        }

        delegate?.addPlayer(with: sprite.node)
    }

    /// Get tne SpriteType for other players based on the number of existing other player
    private func getOtherPlayerSpriteType() -> SpriteType {
        let typeIndex = numOtherPlayers + 1

        return SpriteType.otherPlayers[typeIndex]
    }

    // MARK: - Player

    private func stopCurrentPlayer() {
        guard let sprite = currentPlayer?.get(SpriteComponent.self) else {
            return
        }

        let hasStop = finishingLineSystem.stop(player: sprite)

        if !hasStop {
            return
        }

        powerupSystem.removePowerup(from: sprite)
        delegate?.playerHasFinishRace()
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

    private func findPowerupEntity(for sprite: SKSpriteNode) -> PowerupEntity? {
        for powerup in collectablePowerups {
            guard let powerupSprite = powerup.get(SpriteComponent.self) else {
                continue
            }
            if powerupSprite.node === sprite {
                return powerup
            }
        }
        return nil
    }

    // MARK: - Bots

    private func addBot(sprite: SpriteComponent, botType: BotType) {
        let botEntity = BotEntity(botType: botType)
        guard let botComponent = botEntity.get(BotComponent.self) else {
            return
        }
        botSystem?.add(spriteComponent: sprite, botComponent: botComponent)
        delegate?.addLocalPlayer(with: sprite.node)
    }
}

// MARK: - StartSystemDelegate

extension GameEngine: StartSystemDelegate {
    func isReadyToStart() {
        startCountdown()
    }

    func startGame() {
        gameState = .start
        botSystem?.start()
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

    func hookPlayerApplied(with line: SKShapeNode) {
        delegate?.playerHookToPlayer(with: line)
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

// MARK: - EndSystemDelegate

extension GameEngine: EndSystemDelegate {
    func gameEnded(rankings: [Player]) {
        botSystem?.stopTimer()
        delegate?.gameHasFinish(rankings: rankings)
    }
}

// MARK: - PowerupSystemDelegate

extension GameEngine: PowerupSystemDelegate {
    func collected(powerup: PowerupComponent) {
        guard let powerupEntity = powerup.parent as? PowerupEntity,
            let owner = powerup.owner else {
                return
        }

        Logger.log.show(details: "Appeneded to collectable", logType: .alert)
        collectablePowerups.removeAll(where: { $0 === powerupEntity })
        ownedPowerups.append(powerupEntity)
        if owner === currentPlayer {
            delegate?.hasCollected(powerup: powerup.type)
        }
    }

    func didRemoveOwned(powerup: PowerupComponent) {
        ownedPowerups.removeAll(where: {
            $0.get(PowerupComponent.self) === powerup
        })
    }
}

extension GameEngine: MovementControlDelegate {
    func movement(isDisabled: Bool, for sprite: SpriteComponent) {
        guard let player = sprite.parent as? PlayerEntity else {
            return
        }
        if player === currentPlayer {
            Logger.log.show(details: "Disable movement \(isDisabled)",
                            logType: .information)
            delegate?.movementButton(isDisabled: isDisabled)
        }
    }
}

extension GameEngine: SceneDelegate {
    func hasAdded(node: SKNode) {
        delegate?.hasAdded(node: node)
    }
}

extension GameEngine: PlacementEffectSystemDelegate {
    func hasAddedTrap(sprite spriteComponent: SpriteComponent) {
        _ = spriteSystem.setPhysicsBody(to: spriteComponent, of: .trap,
                                        rectangleOf: spriteComponent.node.size)
        powerupSystem.add(trap: spriteComponent)
        Logger.log.show(details: "Has added trap", logType: .alert)
        delegate?.addTrap(with: spriteComponent.node)
    }
}

extension GameEngine: CutRopeEffectSystemDelegate {
    func forceUnhookFor(player: SpriteComponent) {
        guard let sprite = player.parent.get(SpriteComponent.self),
            let velocity = sprite.node.physicsBody?.velocity else {
            return
        }
        _ = hookSystem?.unhook(entity: player.parent,
                               at: sprite.node.position,
                               with: velocity)
    }
}

extension GameEngine: StealEffectSystemDelegate {
    func didSteal(from sprite1: SpriteComponent,
                  by sprite2: SpriteComponent,
                  with powerup: PowerupComponent
    ) {
        guard let currentPlayerSprite = currentPlayer?.get(SpriteComponent.self) else {
            return
        }

        powerupSystem.removePowerup(from: sprite1)
        powerupSystem.add(powerup: powerup, to: sprite2)
        if currentPlayerSprite === sprite1 {
            delegate?.hasPowerupStolen(powerup: powerup.type)
        } else if currentPlayerSprite === sprite2 {
            delegate?.hasStolen(powerup: powerup.type)
        }
    }
}

extension GameEngine: PlayerHookEffectDelegate {
    func toHook(_ sprite: SpriteComponent,
                from anchorSprite: SpriteComponent) {
        if !finishingLineSystem.hasPlayerFinish(player: sprite) {
            playerHookEffectSystem.hookAndPull(sprite, from: anchorSprite)
        }
    }
}
extension GameEngine: MovementEffectSystemDelegate {}
