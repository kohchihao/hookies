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
    private var currentPlayerId: String?
    private var currentPlayer: SKSpriteNode?

    private var cam: SKCameraNode?
    private var background: Background?
    private var cannon: SKSpriteNode?
    private var finishingLine: SKSpriteNode?

    private var grapplingHookButton: GrapplingHookButton?
    private var jumpButton: JumpButton?

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
        disableGameButtons()
        initialiseCamera()
        initialiseCountdownMessage()
        initialiseGameEngine()
        initialiseCurrentPlayer()
    }

    // MARK: - Update

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
//        handleJumpButton()
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
        if contact.bodyA.node == finishingLine || contact.bodyB.node == finishingLine {
            // TODO: Game Engine
        }
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
        guard let grapplingHookButton = grapplingHookButton, let jumpButton = jumpButton else {
            return
        }
        addChild(cam)
        cam.addChild(grapplingHookButton)
        cam.addChild(jumpButton)
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

    // MARK: - Initialise Game Engine

    private func initialiseGameEngine() {
        guard let gameplayId = gameplayId else {
            return
        }

        guard let cannonNode = self.childNode(withName: "//cannon") as? SKSpriteNode,
            let finishingLineNode = self.childNode(withName: "//ending_line") as? SKSpriteNode
            else {
            return
        }

        var boltsNode = [SKSpriteNode]()
        let bolts = getGameObject(of: GameObjectType.bolt)
        let boltsMovable = getGameObject(of: GameObjectType.boltMovable)
        boltsNode.append(contentsOf: bolts)
        boltsNode.append(contentsOf: boltsMovable)

        gameEngine = GameEngine(
            gameId: gameplayId,
            cannon: cannonNode,
            finishingLine: finishingLineNode,
            bolts: boltsNode
        )

        self.cannon = cannonNode
        self.finishingLine = finishingLineNode
    }

    private func getGameObject(of type: GameObjectType) -> [SKSpriteNode] {
        var objects = [SKSpriteNode]()

        for object in self[type.rawValue] {
            guard let objectNode = object as? SKSpriteNode else {
                return objects
            }

            objects.append(objectNode)
        }

        return objects
    }

    // MARK: - Initialise current player

    private func initialiseCurrentPlayer() {
        guard let gameplayId = gameplayId else {
            return
        }

        // Getting costume
        API.shared.lobby.get(lobbyId: gameplayId, completion: { lobby, error in
            if error != nil {
                return
            }

            guard let currentPlayerId = self.currentPlayerId,
                let cannon = self.cannon
                else {
                return
            }

            guard let costume = lobby?.costumesId[currentPlayerId] else {
                return
            }

            guard let currentPlayer = self.gameEngine?.setCurrentPlayer(
                id: currentPlayerId,
                position: cannon.position,
                image: costume.stringValue
                ) else {
                    return
            }

            self.currentPlayer = currentPlayer
            self.addChild(currentPlayer)
        })
    }

    // MARK: - Centering camera

    private func centerOnNode(node: SKNode) {
        let action = SKAction.move(to: CGPoint(x: node.position.x, y: 0), duration: 0.5)
        self.cam?.run(action)
        self.background?.run(action)
    }

    // MARK: - Count down to start game

    private func startCountdown() {
        countdown(count: count)
    }

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
        launchPlayer()
    }

    private func getLaunchVelocity() -> CGVector {
        let dx = CGFloat(powerLaunch)
        let dy = CGFloat(powerLaunch)

        return CGVector(dx: dx, dy: dy)
    }

    // MARK: - Launch player

    private func launchPlayer() {
        // TODO: Game Engine
    }

    // MARK: - Game Buttons

    private func disableGameButtons() {
        grapplingHookButton?.state = .ButtonNodeStateDisabled
        jumpButton?.state = .ButtonNodeStateHidden
    }

    private func enableGameButtons() {
        grapplingHookButton?.state = .ButtonNodeStateActive
    }

    // MARK: - Player tethering to hook

    private func handlePlayerTetheringToClosestBolt() {
        grapplingHookButton?.touchBeganHandler = handleGrapplingHookBtnTouchBegan
        grapplingHookButton?.touchEndHandler = handleGrapplingHookBtnTouchEnd
    }

    private func handleGrapplingHookBtnTouchBegan() {
        // TODO: Game Engine
    }

    private func handleGrapplingHookBtnTouchEnd() {
        // TODO: Game Engine
    }

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
        currentPlayer?.physicsBody?.applyImpulse(CGVector(dx: 500, dy: 500))
    }

    private func handleJumpButtonTouchEnd() {
        jumpButton?.state = .ButtonNodeStateHidden
    }
}
