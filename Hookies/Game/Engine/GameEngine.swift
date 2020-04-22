//
//  GameEngine.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//
import SpriteKit

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

    // MARK: - Entity

    private var currentPlayer: PlayerEntity?
    private var otherPlayers = [String: PlayerEntity]()
    private var platforms = [PlatformEntity]()
    private var bolts = [BoltEntity]()
    private var powerups = [PowerupEntity]()
    private var cannon = CannonEntity()
    private var finishingLine = FinishingLineEntity()

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
        Logger.log.traceableFunctionName = true
    }

    private func initialiseDelegates() {
        startSystem.delegate = self
        hookSystem?.delegate = self
        userConnectionSystem?.delegate = self
        powerupSystem.delegate = self
    }

    // MARK: - Add Players

    func addPlayers(_ players: [Player]) {
        initialisePlayers(players)
        startSystem.getReady()

        endSystem = EndSystem(totalPlayers: players.count)
        endSystem?.delegate = self
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
        guard let currentPlayer = currentPlayer,
            let playerSprite = currentPlayer.get(SpriteComponent.self) else {
            return
        }
        powerupSystem.activateAndBroadcast(powerupType: type,
                                           for: playerSprite)
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

    // MARK: - Contact with Powerups

    func currentPlayerContactWith(powerup: SKSpriteNode) -> PowerupType? {
        guard let playerSprite = currentPlayer?.get(SpriteComponent.self),
            let powerupEntity = findPowerupEntity(for: powerup),
            let powerupSprite = powerupEntity.getSpriteComponent(),
            let powerupComponent = powerupEntity.get(PowerupComponent.self) else {
                return nil
        }

        powerups.removeAll(where: { $0 === powerupEntity })
        spriteSystem.removePhysicsBody(to: powerupSprite)
        powerupSystem.collectAndBroadcast(powerupComponent: powerupComponent,
                                          by: playerSprite)
        return powerupComponent.type
    }

    func currentPlayerContactWith(trap: SKSpriteNode) {
        guard let currentPlayer = currentPlayer,
            let currentPlayerSprite = currentPlayer.get(SpriteComponent.self) else {
                Logger.log.show(details: "Unable to locate current player", logType: .error)
                return
        }
        powerupSystem.activateNetTrapAndBroadcast(at: trap.position, on: currentPlayerSprite)
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
        let randType = [PowerupType.shield, PowerupType.stealPowerup,
                        PowerupType.playerHook].randomElement() ?? .shield
//        let randType = PowerupType.allCases.randomElement() ?? .shield
        addNewPowerup(with: randType, for: spriteNode)
    }

    private func addNewPowerup(with type: PowerupType,
                               for spriteNode: SKSpriteNode
    ) {
        guard let powerupEntity = createPowerup(with: type, for: spriteNode),
            let powerupComponent = powerupEntity.get(PowerupComponent.self) else {
            return
        }
        powerups.append(powerupEntity)
        powerupSystem.add(powerup: powerupComponent)
    }

    private func createPowerup(with type: PowerupType,
                               for spriteNode: SKSpriteNode
    ) -> PowerupEntity? {
        let powerupEntity = PowerupEntity(for: type)
        guard let powerupSprite = powerupEntity.get(SpriteComponent.self) else {
            return nil
        }
        _ = spriteSystem.set(sprite: powerupSprite, to: spriteNode)
        _ = spriteSystem.setPhysicsBody(to: powerupSprite, of: .powerup,
                                        rectangleOf: powerupSprite.node.size)
        return powerupEntity
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
        hookSystem?.add(player: sprite)
        powerupSystem.add(player: sprite)

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
        hookSystem?.add(player: sprite)
        powerupSystem.add(player: sprite)

        delegate?.addPlayer(with: sprite.node)
    }

    private func getOtherPlayerSpriteType() -> SpriteType {
        let numOtherPlayers = otherPlayers.count
        let typeIndex = numOtherPlayers + 1

        return SpriteType.otherPlayers[typeIndex]
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
        for powerup in powerups {
            guard let powerupSprite = powerup.get(SpriteComponent.self) else {
                continue
            }
            if powerupSprite.node === sprite {
                return powerup
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
        delegate?.gameHasFinish(rankings: rankings)
    }
}

// MARK: - PowerupSystemDelegate

extension GameEngine: PowerupSystemDelegate {
    func collected(powerup: PowerupComponent, by sprite: SpriteComponent) {
        guard let powerupEntity = powerup.parent as? PowerupEntity else {
            return
        }
        powerups.removeAll(where: { $0 === powerupEntity })
    }

    func hasAddedTrap(sprite spriteComponent: SpriteComponent) {
        _ = spriteSystem.setPhysicsBody(to: spriteComponent, of: .netTrap,
                                        rectangleOf: spriteComponent.node.size)
        delegate?.addTrap(with: spriteComponent.node)
    }

    func hook(_ sprite: SpriteComponent,
              from anchorSprite: SpriteComponent) {
        if !finishingLineSystem.hasPlayerFinish(player: sprite) {
            hookSystem?.hookAndPull(sprite, from: anchorSprite)
        }
    }

    func forceUnhookFor(player: SpriteComponent) {
        guard let sprite = player.parent.get(SpriteComponent.self),
            let velocity = sprite.node.physicsBody?.velocity else {
            return
        }
        _ = hookSystem?.unhook(entity: player.parent,
                               at: sprite.node.position,
                               with: velocity)
    }

    func indicateSteal(from sprite1: SpriteComponent,
                       by sprite2: SpriteComponent,
                       with powerup: PowerupComponent
    ) {
        guard let currentPlayerSprite = currentPlayer?.get(SpriteComponent.self) else {
            return
        }
        if currentPlayerSprite === sprite1 {
            delegate?.hasPowerupStolen(powerup: powerup.type)
        } else if currentPlayerSprite === sprite2 {
            delegate?.hasStolen(powerup: powerup.type)
        }
    }
}

extension GameEngine: MovementControlDelegate {
    func movement(isDisabled: Bool, for sprite: SpriteComponent) {
        guard let player = sprite.parent as? PlayerEntity else {
            return
        }
        if player === currentPlayer {
            Logger.log.show(details: "Disable movement", logType: .information)
            delegate?.movementButton(isDisabled: isDisabled)
        }
    }
}
