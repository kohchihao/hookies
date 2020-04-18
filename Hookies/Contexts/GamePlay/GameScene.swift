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
    var gameplayId: String?
    var players = [Player]()
    private var currentPlayerId: String?
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

    private var signal: Signal?

    private var countdownLabel: SKLabelNode?
    private var count = 5

    private var gameEngine: GameEngine?

    weak var viewController: GamePlayViewController!

    private var powerLaunch = 1_000

    override func didMove(to view: SKView) {
        currentPlayerId = API.shared.user.currentUser?.uid

        initialiseContactDelegate()
        initialiseBackground(with: view.frame.size)
        initialiseGrapplingHookButton()
        initialiseJumpButton()
        initialisePowerupButton()
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
        handleJumpButton()
    }

    override func didFinishUpdate() {
        guard let currentPlayer = currentPlayer else {
            return
        }
        centerOnNode(node: currentPlayer)
    }

    func setPowerLaunch(at power: Int) {
        powerLaunch = power
    }

     // MARK: - Collision Detection

    func didBegin(_ contact: SKPhysicsContact) {
        guard has(contact: contact, with: currentPlayer) else {
                return
        }

        if has(contact: contact, with: finishingLine) {
            gameEngine?.stopCurrentPlayer()
        }

        for powerup in powerups where has(contact: contact, with: powerup) {
            handleContactWithPowerup(powerup)
        }

        for trap in traps where has(contact: contact, with: trap) {
            handleContactWithTrap(trap)
        }
    }

    private func has(contact: SKPhysicsContact, with node: SKSpriteNode?) -> Bool {
        return contact.bodyA.node == node ||
            contact.bodyB.node == node
    }

    private func handleContactWithTrap(_ trap: SKSpriteNode) {
        guard let playerId = currentPlayerId else {
            return
        }
        gameEngine?.playerContactWith(trap: trap,
                                      playerId: playerId)
    }

    private func handleContactWithPowerup(_ powerup: SKSpriteNode) {
        guard let powerupType = gameEngine?.currentPlayerContactWith(powerup: powerup) else {
            return
        }
        powerups.removeAll(where: { $0 == powerup })
        let texture = SKTexture(imageNamed: powerupType.buttonString)
        let sizeOfPowerup = CGSize(width: 50, height: 50)
        let powerupDisplay = SKSpriteNode(texture: texture, color: .clear,
                                          size: sizeOfPowerup)
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
            let powerupButton = powerupButton
            else {
                return
        }
        addChild(cam)
        cam.addChild(grapplingHookButton)
        cam.addChild(jumpButton)
        cam.addChild(powerupButton)
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

    // MARK: - Initialise Game Engine

    private func initialiseGameEngine() {
        let cannonObject = getGameObjects(of: .cannon)[0]
        let finishingLineObject = getGameObjects(of: .finishingLine)[0]
        let boltObjects = getGameObjects(of: .bolt)
        let powerupObjects = getGameObjects(of: .powerup)
        let platformObjects = getGameObjects(of: .platform)

        let powerupNodes = getGameNodes(of: .powerup)

        gameEngine = GameEngine(
            cannon: cannonObject,
            finishingLine: finishingLineObject,
            bolts: boltObjects,
            powerups: powerupObjects,
            platforms: platformObjects,
            players: players
        )

        gameEngine?.delegate = self

        self.cannon = cannonObject.node
        self.finishingLine = finishingLineObject.node
        self.powerups = powerupNodes
    }

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

    private func centerOnNode(node: SKNode) {
        let action = SKAction.move(to: CGPoint(x: node.position.x, y: 0), duration: 0.5)
        self.cam?.run(action)
        self.background?.run(action)
    }

    // MARK: - Count down to start game

    func countdown(count: Int) {
        countdownLabel?.text = "Launching player in \(count)..."

        let counterDecrement = SKAction.sequence([SKAction.wait(forDuration: 1.0),
                                                  SKAction.run(countdownAction)])

        run(SKAction.sequence([SKAction.repeat(counterDecrement, count: count), SKAction.run(endCountdown)]))

    }

    private func countdownAction() {
        count -= 1
        countdownLabel?.text = "Launching player in \(count)..."
    }

    private func endCountdown() {
        enableGameButtons()
        countdownLabel?.removeFromParent()
        viewController.hidePowerSlider()
        launchCurrentPlayer()
        gameEngine?.startGame()
    }

    private func getLaunchVelocity() -> CGVector {
        let dx = CGFloat(powerLaunch)
        let dy = CGFloat(powerLaunch)

        return CGVector(dx: dx, dy: dy)
    }

    // MARK: - Launch player

    private func launchCurrentPlayer() {
        let velocity = getLaunchVelocity()
        gameEngine?.launchCurrentPlayer(with: velocity)

        cannon?.removeFromParent()
    }

    // MARK: - Game Buttons

    private func disableGameButtons() {
        grapplingHookButton?.state = .ButtonNodeStateDisabled
        jumpButton?.state = .ButtonNodeStateHidden
    }

    private func enableGameButtons() {
        grapplingHookButton?.state = .ButtonNodeStateActive
    }

    // MARK: - Current player tethering to hook

    private func handleCurrentPlayerTetheringToClosestBolt() {
        grapplingHookButton?.touchBeganHandler = handleGrapplingHookBtnTouchBegan
        grapplingHookButton?.touchEndHandler = handleGrapplingHookBtnTouchEnd
        grapplingHookButton?.touchUpHandler = handleGrapplingHookBtnUp
        grapplingHookButton?.touchDownHandler = handleGrapplingHookBtnDown
    }

    private func handleGrapplingHookBtnUp() {
        gameEngine?.applyShortenActionToCurrentPlayer()
    }

    private func handleGrapplingHookBtnDown() {
        gameEngine?.applyLengthenActionToCurrentPlayer()
    }

    // MARK: - Current player activating power up

    private func handleCurrentPlayerActivatePowerup() {
        powerupButton?.touchBeganHandler = handlePowerupBtnTouch
        powerupButton?.touchEndHandler = handlePowerupBtnTouchEnd
    }

    private func handlePowerupBtnTouch() {
        guard let powerupType = powerupButton?.powerupType else {
            return
        }
        gameEngine?.currentPlayerPowerupAction(with: powerupType)
    }

    private func handleGrapplingHookBtnTouchBegan() {
        gameEngine?.applyHookActionToCurrentPlayer()
    }

    private func handlePowerupBtnTouchEnd() {
        powerupButton?.clearPowerup()
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

    func addPlayer(with sprite: SKSpriteNode) {
        addChild(sprite)
    }

    func currentPlayerIsReconnected() {
        reconnectPlayer()
    }

    func currentPlayerIsDisconnected() {
        disconnectPlayer()
    }

    func gameHasFinish() {
        print("Transition to post game lobby")
        viewController.endGame()
    }
}
