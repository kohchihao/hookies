//
//  GameScene.swift
//  Hookies
//
//  Created by Tan LongBin on 7/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit
import GameplayKit
import Dispatch

class GameScene: SKScene, SKPhysicsContactDelegate {
    var players = [Player]()
    private var currentPlayer: SKSpriteNode?

    private var cam: SKCameraNode?
    private var background: Background?
    private var cannon: SKSpriteNode?
    private var finishingLine: SKSpriteNode?
    private var powerups: [SKSpriteNode] = []
    private var traps: [SKSpriteNode] = []

    private var grapplingHookButton: GrapplingHookButton?
    private var jumpButton: JumpButton?
    private var powerupButton: PowerupButton?
    private var lengthenButton: LengthenButton?
    private var shortenButton: ShortenButton?

    private var signal: Signal?

    private var countdownLabel: SKLabelNode?
    private var count = 5

    private var localPlayers: [SKSpriteNode] = []

    private var gameEngine: GameEngine?

    weak var viewController: GamePlayViewController!

    private var powerLaunch = 1_000

    override func didMove(to view: SKView) {
        initialiseContactDelegate()
        initialiseBackground(with: view.frame.size)
        initialiseGrapplingHookButton()
        initialiseJumpButton()
        initialisePowerupButton()
        initialiseShortenButton()
        initialiseLengthenButton()
        disableGameButtons()
        initialiseCamera()
        initialiseCountdownMessage()
        initialiseGameEngine()
    }

    // MARK: - Update

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        gameEngine?.update(time: currentTime)
        handleCurrentPlayerTetheringToClosestBolt()
        handleCurrentPlayerActivatePowerup()
        handleCurrentPlayerAdjustRope()
        handleJumpButton()
    }

    override func didFinishUpdate() {
        guard let currentPlayer = currentPlayer else {
            return
        }
        centerOnNode(node: currentPlayer)
    }

    /// Set the power launch.
    /// - Parameter power: The power to launch at
    func setPowerLaunch(at power: Int) {
        powerLaunch = power
    }

     // MARK: - Collision Detection

    func didBegin(_ contact: SKPhysicsContact) {
        for player in localPlayers {
            if has(contact: contact, with: player) {
                if has(contact: contact, with: finishingLine) {
                    gameEngine?.stopLocalPlayer(playerNode: player)
                    return
                }
                for trap in traps where has(contact: contact, with: trap) {
                    handleContactWithTrap(between: player, trap: trap)
                    return
                }
                if player == currentPlayer {
                    for powerup in powerups where has(contact: contact, with: powerup) {
                        handleContactWithPowerup(powerup)
                        return
                    }
                }
            }
        }
    }

    /// Checks if there is a contact between 2 sprites.
    /// - Parameters:
    ///   - contact: The contact between sprites
    ///   - node: The node to check with
    private func has(contact: SKPhysicsContact, with node: SKSpriteNode?) -> Bool {
        return contact.bodyA.node == node || contact.bodyB.node == node
    }

    /// Handles the contact with traps.
    /// - Parameters:
    ///   - player: The player that is trapped
    ///   - trap: The trap itself
    private func handleContactWithTrap(between player: SKSpriteNode, trap: SKSpriteNode) {
        gameEngine?.contactBetween(playerNode: player, trap: trap)
    }

    /// Handles the contact with power up chests.
    /// - Parameter powerup: The power up chest
    private func handleContactWithPowerup(_ powerup: SKSpriteNode) {
        powerups.removeAll(where: { $0 == powerup })
        animateDisappear(of: powerup)
    }

    /// Animate the removal of power up chest
    /// - Parameter powerup: The power up chest
    private func animateDisappear(of powerup: SKSpriteNode) {
        guard let powerupType = gameEngine?.currentPlayerContactWith(powerup: powerup) else {
            return
        }

        let powerupDisplay = powerupType.buttonNode
        powerupDisplay.position = powerup.position
        powerupDisplay.zPosition = 0
        addChild(powerupDisplay)

        let finalPosition = CGPoint(x: powerupDisplay.position.x,
                                    y: powerupDisplay.position.y + 60)
        let powerupAnimation = SKAction.sequence([SKAction.move(to: finalPosition, duration: 1),
                                                  SKAction.fadeOut(withDuration: 0.5)])
        powerupDisplay.run(powerupAnimation, completion: {
            powerupDisplay.removeFromParent()
            self.powerupButton?.setPowerup(to: powerupType)
        })
    }

    // MARK: - Initialise contact delegate

    private func initialiseContactDelegate() {
        physicsWorld.contactDelegate = self
    }

    // MARK: - Initialise background

    private func initialiseBackground(with size: CGSize) {
        background = Background(in: size)
        guard let background = background else {
            return
        }
        addChild(background)
    }

     // MARK: - Initialise Camera

    private func initialiseCamera() {
        cam = SKCameraNode()
        self.camera = cam
        guard let cam = cam else {
            return
        }
        guard let grapplingHookButton = grapplingHookButton,
            let jumpButton = jumpButton,
            let powerupButton = powerupButton,
            let lengthenButton = lengthenButton,
            let shortenButton = shortenButton
            else {
                return
        }
        addChild(cam)
        cam.addChild(grapplingHookButton)
        cam.addChild(jumpButton)
        cam.addChild(powerupButton)
        cam.addChild(lengthenButton)
        cam.addChild(shortenButton)
    }

    // MARK: - Initialise Countdown message

    private func initialiseCountdownMessage() {
        countdownLabel = SKLabelNode()
        countdownLabel?.position = CGPoint(x: 0, y: 0)
        countdownLabel?.fontColor = .black
        countdownLabel?.fontSize = size.height / 30
        countdownLabel?.zPosition = 100
        countdownLabel?.text = "Waiting for players..."

        self.cam?.addChild(countdownLabel!)
    }

    // MARK: - Initialise Grappling Hook button

    private func initialiseGrapplingHookButton() {
        guard let sceneFrame = self.scene?.frame else {
            return
        }
        grapplingHookButton = GrapplingHookButton(in: sceneFrame)
    }

    // MARK: - Initialise Powerup button

    private func initialisePowerupButton() {
        guard let sceneFrame = self.scene?.frame else {
            return
        }
        powerupButton = PowerupButton(in: sceneFrame)
    }

    // MARK: - Initialise Lengthen button

    private func initialiseLengthenButton() {
        guard let sceneFrame = self.scene?.frame else {
            return
        }
        lengthenButton = LengthenButton(in: sceneFrame)
    }

    // MARK: - Initialise Shorten button

    private func initialiseShortenButton() {
        guard let sceneFrame = self.scene?.frame else {
            return
        }
        shortenButton = ShortenButton(in: sceneFrame)
    }

    // MARK: - Initialise Game Engine

    private func initialiseGameEngine() {
        let cannonObject = getGameObjects(of: .cannon)[0]
        let finishingLineObject = getGameObjects(of: .finishingLine)[0]
        let boltObjects = getGameObjects(of: .bolt)
        let powerupObjects = getGameObjects(of: .powerup)
        let platformObjects = getGameObjects(of: .platform)

        let powerupNodes = getGameNodes(of: .powerup)

        let hasBot = players.contains(where: { $0.isCurrentPlayer && $0.isHost })

        gameEngine = GameEngine(
            cannon: cannonObject,
            finishingLine: finishingLineObject,
            bolts: boltObjects,
            powerups: powerupObjects,
            platforms: platformObjects,
            hasBot: hasBot
        )

        gameEngine?.delegate = self
        gameEngine?.addPlayers(players)

        self.cannon = cannonObject.node
        self.finishingLine = finishingLineObject.node
        self.powerups = powerupNodes
    }

    /// Get the nodes within the Game Scene.
    /// - Parameter type: The type of game object
    private func getGameNodes(of type: GameObjectType) -> [SKSpriteNode] {
        var nodes = [SKSpriteNode]()

        for node in self["//" + type.rawValue + "*"] {
            guard let spriteNode = node as? SKSpriteNode else {
                return nodes
            }

            nodes.append(spriteNode)
        }

        return nodes
    }

    /// Get the game object within the Game Scene.
    /// - Parameter type: The type of game object
    private func getGameObjects(of type: GameObjectType) -> [GameObject] {
        var objects = [GameObject]()

        for object in self["//" + type.rawValue + "*"] {
            guard let objectNode = object as? SKSpriteNode else {
                return objects
            }

            let gameObject = GameObject(node: objectNode, type: type)
            objects.append(gameObject)
        }

        return objects
    }

    // MARK: - Centering camera

    /// Center the camera.
    /// - Parameter node: The node to center on
    private func centerOnNode(node: SKNode) {
        let action = SKAction.move(to: CGPoint(x: node.position.x, y: 0), duration: 0.5)
        self.cam?.run(action)
        self.background?.run(action)
    }

    // MARK: - Count down to start game

    /// Animate the countdown sequence.
    /// - Parameter count: The time to countdown to
    private func countdown(count: Int) {
        countdownLabel?.text = "Launching player in \(count)..."

        let counterDecrement = SKAction.sequence([SKAction.wait(forDuration: 1.0),
                                                  SKAction.run(countdownAction)])

        run(SKAction.sequence([SKAction.repeat(counterDecrement, count: count), SKAction.run(endCountdown)]))

    }

    /// Update the countdown message.
    private func countdownAction() {
        count -= 1
        countdownLabel?.text = "Launching player in \(count)..."
    }

    /// End the count down and start the game engine.
    private func endCountdown() {
        enableGameButtons()
        countdownLabel?.removeFromParent()
        viewController.hidePowerSlider()
        launchLocalPlayers()
        gameEngine?.startGame()
    }

    private func getLaunchVelocity() -> CGVector {
        let dx = CGFloat(powerLaunch)
        let dy = CGFloat(powerLaunch)

        return CGVector(dx: dx, dy: dy)
    }

    // MARK: - Launch local player and bots

    private func launchLocalPlayers() {
        let velocity = getLaunchVelocity()
        gameEngine?.launchLocalPlayers(with: velocity)

        cannon?.removeFromParent()
    }

    // MARK: - Game Buttons

    private func disableGameButtons() {
        grapplingHookButton?.state = .ButtonNodeStateDisabled
        jumpButton?.state = .ButtonNodeStateHidden
        shortenButton?.state = .ButtonNodeStateDisabled
        lengthenButton?.state = .ButtonNodeStateDisabled
        powerupButton?.state = .ButtonNodeStateDisabled
    }

    private func enableGameButtons() {
        grapplingHookButton?.state = .ButtonNodeStateActive
        shortenButton?.state = .ButtonNodeStateActive
        lengthenButton?.state = .ButtonNodeStateActive
    }

    // MARK: - Current player tethering to hook

    private func handleCurrentPlayerTetheringToClosestBolt() {
        grapplingHookButton?.touchBeganHandler = handleGrapplingHookBtnTouchBegan
        grapplingHookButton?.touchEndHandler = handleGrapplingHookBtnTouchEnd
    }

    private func handleCurrentPlayerAdjustRope() {
        shortenButton?.touchBeganHandler = handleShortening
        lengthenButton?.touchBeganHandler = handleLengthening
    }

    private func handleShortening() {
        gameEngine?.applyShortenActionToCurrentPlayer()
    }

    private func handleLengthening() {
        gameEngine?.applyLengthenActionToCurrentPlayer()
    }

    // MARK: - Current player activating power up

    private func handleCurrentPlayerActivatePowerup() {
        powerupButton?.touchEndHandler = handlePowerupBtnTouchEnd
    }

    private func handleGrapplingHookBtnTouchBegan() {
        gameEngine?.applyHookActionToCurrentPlayer()
    }

    private func handlePowerupBtnTouchEnd() {
        guard let powerupType = powerupButton?.powerupType else {
            return
        }
        powerupButton?.clearPowerup()
        gameEngine?.currentPlayerPowerupAction(with: powerupType)
    }

    private func handleGrapplingHookBtnTouchEnd() {
        gameEngine?.applyUnhookActionToCurrentPlayer()
    }

    // MARK: - Resolve deadlock

    private func initialiseJumpButton() {
        guard let sceneFrame = self.scene?.frame else {
            return
        }
        jumpButton = JumpButton(in: sceneFrame)
    }

    private func handleJumpButton() {
        jumpButton?.touchBeganHandler = handleJumpButtonTouched
        jumpButton?.touchEndHandler = handleJumpButtonTouchEnd
    }

    private func handleJumpButtonTouched() {
        gameEngine?.currentPlayerJumpAction()
    }

    private func handleJumpButtonTouchEnd() {
        jumpButton?.state = .ButtonNodeStateHidden
    }

    // MARK: - Connection

    private func reconnectPlayer() {
        signal?.removeFromParent()
        signal = nil
    }

    private func disconnectPlayer() {
        initialiseSignal()
    }

    private func initialiseSignal() {
        guard signal == nil else {
            return
        }

        guard let sceneFrame = self.scene?.frame else {
            return
        }

        let signal = Signal(in: sceneFrame)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let blinking = SKAction.sequence([fadeOut, fadeIn])
        signal.run(SKAction.repeatForever(blinking))

        cam?.addChild(signal)

        self.signal = signal
    }
}

// MARK: - GameEngineDelegate

extension GameScene: GameEngineDelegate {
    func startCountdown() {
        countdown(count: count)
    }

    func playerDidHook(to hook: HookDelegateModel) {
        addChild(hook.line)
        physicsWorld.add(hook.anchorLineJointPin)
        physicsWorld.add(hook.playerLineJointPin)
    }

    func playerDidUnhook(from hook: HookDelegateModel) {
        hook.line.removeFromParent()
        physicsWorld.remove(hook.anchorLineJointPin)
        physicsWorld.remove(hook.playerLineJointPin)
    }

    func playerIsStuck() {
        jumpButton?.state = .ButtonNodeStateActive
    }

    func addNotActivatedPowerup(_ sprite: SKSpriteNode) {
        powerups.append(sprite)
        addChild(sprite)
        let fadeIn = SKAction.fadeIn(withDuration: 1)
        sprite.run(fadeIn)
    }

    func addTrap(with sprite: SKSpriteNode) {
        addChild(sprite)
        traps.append(sprite)
    }

    func playerHasFinishRace() {
        disableGameButtons()
    }

    func addCurrentPlayer(with sprite: SKSpriteNode) {
        addChild(sprite)
        currentPlayer = sprite
        localPlayers.append(sprite)
    }

    func addPlayer(with sprite: SKSpriteNode) {
        addChild(sprite)
    }

    func addLocalPlayer(with sprite: SKSpriteNode) {
        localPlayers.append(sprite)
    }

    func currentPlayerIsReconnected() {
        reconnectPlayer()
    }

    func currentPlayerIsDisconnected() {
        disconnectPlayer()
    }

    func gameHasFinish(rankings: [Player]) {
        Logger.log.show(details: "Transition to post game lobby", logType: .information)
        viewController.endGame(rankings: rankings)
    }

    func movementButton(isDisabled: Bool) {
        let newState: ButtonNodeState = isDisabled ?
            .ButtonNodeStateDisabled :
            .ButtonNodeStateActive

        grapplingHookButton?.state = newState
        jumpButton?.state = newState
        shortenButton?.state = newState
        lengthenButton?.state = newState
    }

    func playerHookToPlayer(with line: SKShapeNode) {
        addChild(line)
    }

    func hasPowerupStolen(powerup: PowerupType) {
        guard let powerupButton = powerupButton else {
            return
        }

        powerupButton.clearPowerup()
        let node = powerup.buttonNode
        node.position = powerupButton.position

        let finalPos = CGPoint(x: node.position.x - 100.0, y: node.position.y)
        let animate = SKAction.sequence([SKAction.move(to: finalPos, duration: 1),
                                         SKAction.fadeOut(withDuration: 0.5)])

        let message = SKLabelNode(text: "Stolen!")
        message.fontName = "AvenirNext-Bold"
        message.fontColor = .red
        message.fontSize = 50
        message.position = CGPoint(x: node.position.x, y: node.position.y - 70)

        cam?.addChild(node)
        cam?.addChild(message)
        node.run(animate, completion: {
            node.removeFromParent()
            message.removeFromParent()
        })
    }

    func hasStolen(powerup: PowerupType) {
        guard let powerupButton = powerupButton else {
            return
        }
        let node = powerup.buttonNode
        node.position = CGPoint(x: powerupButton.position.x + 100,
                                y: powerupButton.position.y)

        let finalPos = powerupButton.position
        let animate = SKAction.move(to: finalPos, duration: 1)

        let message = SKLabelNode(text: "Retrieved!")
        message.fontName = "AvenirNext-Bold"
        message.fontColor = .green
        message.fontSize = 50
        message.position = CGPoint(x: node.position.x, y: node.position.y - 70)

        cam?.addChild(node)
        cam?.addChild(message)
        node.run(animate, completion: {
            node.removeFromParent()
            message.removeFromParent()
            powerupButton.setPowerup(to: powerup)
        })
    }
}
