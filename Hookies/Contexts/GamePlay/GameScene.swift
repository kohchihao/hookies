//
//  GameScene.swift
//  Hookies
//
//  Created by Tan LongBin on 7/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // TODO: To remove
    let playerId = "id"
    let playerImage = "Owlet_Monster"

    private var isTouching = false
    private var player: Player?
    private var cannon: Cannon?
    private var finishingLine: SKSpriteNode?
    private var cam: SKCameraNode?

    private var background: Background?
    private var grapplingHookButton: GrapplingHookButton?
    private var countdownLabel: SKLabelNode?
    private var count = 2
    private var hasPlayerFinishRace = false

    private var playerAttachedAnchor: SKNode?
    private var anchorToPlayerLineJointPin: SKPhysicsJointPin?
    private var playerLineToPlayerPositionJointPin: SKPhysicsJointPin?

    weak var viewController: GamePlayViewController!

    private var powerLaunch = 2_000

    override func didMove(to view: SKView) {
        initialiseContactDelegate()
        initialiseBackground(with: view.frame.size)
        initialiseGrapplingHookButton()
        initialiseCamera()
        initialiseFinishingLinePhysicsBody()

        guard let cannonNode = self.childNode(withName: "//cannon") as? SKSpriteNode else {
                return
        }
        cannon = Cannon(node: cannonNode)

        initialisePlayer(at: cannonNode.position)
        countdown(count: count)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = true
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        updatePlayerClosestBolt()
        handlePlayerTetheringToClosestBolt()
        handlePlayerAfterFinishingLine()
    }

    func setPowerLaunch(at power: Int) {
        powerLaunch = power
    }

     // MARK: - Collision Detection

    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == finishingLine || contact.bodyB.node == finishingLine {
            handlePlayerAtFinishingLine()
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
        guard let grapplingHookButton = grapplingHookButton else {
            return
        }
        addChild(cam)
        cam.addChild(grapplingHookButton)
    }

     // MARK: - Initialise Grappling Hook button

    private func initialiseGrapplingHookButton() {
        guard let sceneFrame = self.scene?.frame else {
            return
        }
        grapplingHookButton = GrapplingHookButton(in: sceneFrame)
    }

    // MARK: - Initialise Finishing Line Physics Body

    private func initialiseFinishingLinePhysicsBody() {
        let type = SpriteType.finishingLine

        guard let finishingLine = self.childNode(withName: "//ending_line") as? SKSpriteNode else {
            return
        }

        finishingLine.physicsBody = SKPhysicsBody(rectangleOf: finishingLine.size)
        finishingLine.physicsBody?.isDynamic = type.isDynamic
        finishingLine.physicsBody?.allowsRotation = type.isDynamic
        finishingLine.physicsBody?.affectedByGravity = type.affectedByGravity
        finishingLine.physicsBody?.categoryBitMask = type.bitMask

        self.finishingLine = finishingLine
    }

    // MARK: - Initialise Player

    private func initialisePlayer(at position: CGPoint) {
        guard let playerClosestBolt = getNearestBolt(from: position) else {
            return
        }

        self.player = Player(
            id: playerId,
            position: position,
            imageName: playerImage,
            closestBolt: playerClosestBolt
        )

        guard let player = player else {
            return
        }
        addChild(player.node)
    }

    // MARK: - Centering camera

    private func centerOnNode(node: SKNode) {
        let action = SKAction.move(to: CGPoint(x: node.position.x, y: 0), duration: 0.5)
        self.cam?.run(action)
        self.background?.run(action)
    }

    override func didFinishUpdate() {
        guard let player = player else {
            return
        }
        centerOnNode(node: player.node)
    }

    // MARK: - Launch player

    private func launchPlayer() {
        guard let player = player else {
            return
        }
        let velocity = getLaunchVelocity()
        cannon?.launch(player: player, with: velocity)
        cannon?.node.removeFromParent()
    }

    // MARK: - Count down to start game

    private func startCountdown() {
        disableGameButtons()
    }

    private func countdown(count: Int) {
        startCountdown()

        countdownLabel = SKLabelNode()
        countdownLabel?.position = CGPoint(x: 0, y: 0)
        countdownLabel?.fontColor = .black
        countdownLabel?.fontSize = size.height / 30
        countdownLabel?.zPosition = 100
        countdownLabel?.text = "Launching player in \(count)..."

        self.cam?.addChild(countdownLabel!)

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

    // MARK: - Calculate nearest bolt

    private func getNearestBolt(from position: CGPoint) -> SKSpriteNode? {
        let allBolts = self["bolt"] // getting all the bolts within the scene.
        var closestBolt: SKSpriteNode?
        var closestDistance = Double.greatestFiniteMagnitude
        for bolt in allBolts {
            let boltPosition = bolt.position
            let distanceX = boltPosition.x - position.x
            let distanceY = boltPosition.y - position.y
            let distance = sqrt(distanceX * distanceX + distanceY * distanceY)
            closestDistance = min(Double(distance), closestDistance)
            if closestDistance == Double(distance) {
                closestBolt = bolt as? SKSpriteNode
            }
        }
        enumerateChildNodes(withName: "bolt") { node, _ in
            node.isHidden = false
        }

        return closestBolt
    }

    private func getLaunchVelocity() -> CGVector {
        let dx = CGFloat(powerLaunch)
        let dy = CGFloat(powerLaunch)

        return CGVector(dx: dx, dy: dy)
    }

    // MARK: - Game Buttons

    private func disableGameButtons() {
        guard let grapplingHookButton = grapplingHookButton else {
            return
        }

        grapplingHookButton.state = .ButtonNodeStateDisabled
    }

    private func enableGameButtons() {
        guard let grapplingHookButton = grapplingHookButton else {
            return
        }

        grapplingHookButton.state = .ButtonNodeStateActive
    }

    private func updatePlayerClosestBolt() {
        guard let player = player else {
            return
        }

        guard let playerClosestBolt = getNearestBolt(from: player.node.position) else {
            return
        }

        player.closestBolt = playerClosestBolt
    }

    // MARK: - Player tethering to hook

    private func handlePlayerTetheringToClosestBolt() {
        guard let grapplingHookButton = grapplingHookButton else {
            return
        }

        grapplingHookButton.touchBeganHandler = {
            self.handleGrapplingHookBtnTouchBegan()
        }

        grapplingHookButton.touchEndHandler = {
            self.handleGrapplingHookBtnTouchEnd()
        }
    }

    private func handleGrapplingHookBtnTouchBegan() {
        self.player?.tetherToClosestBolt()

        guard let playerPosition = self.player?.node.position,
            let playerLine = self.player?.line,
            let playerAttachedBolt = self.player?.attachedBolt else {
                return
        }

        let anchor = SKNode()
        anchor.position = playerAttachedBolt.position
        anchor.physicsBody = SKPhysicsBody()
        anchor.physicsBody?.isDynamic = SpriteType.bolt.isDynamic

        self.addChild(anchor)
        self.addChild(playerLine)
        playerAttachedAnchor = anchor

        guard let anchorPhysicsBody = anchor.physicsBody,
            let linePhysicsBody = playerLine.physicsBody,
            let playerPhyscisBody = self.player?.node.physicsBody else {
                return
        }

        let boltToLine = SKPhysicsJointPin.joint(
            withBodyA: anchorPhysicsBody,
            bodyB: linePhysicsBody,
            anchor: anchor.position
        )
        self.physicsWorld.add(boltToLine)
        self.anchorToPlayerLineJointPin = boltToLine

        let lineToPlayer = SKPhysicsJointPin.joint(
            withBodyA: playerPhyscisBody,
            bodyB: linePhysicsBody,
            anchor: playerPosition
        )
        self.physicsWorld.add(lineToPlayer)
        self.playerLineToPlayerPositionJointPin = lineToPlayer
    }

    private func handleGrapplingHookBtnTouchEnd() {
        guard let playerLine = self.player?.line,
            let playerAttachedAnchor = self.playerAttachedAnchor,
            let anchorToPlayerLineJointPin = self.anchorToPlayerLineJointPin,
            let playerLineToPlayerPositionJointPin = self.playerLineToPlayerPositionJointPin else {
            return
        }

        self.player?.releaseFromBolt()
        playerLine.removeFromParent()

        playerAttachedAnchor.removeFromParent()
        self.physicsWorld.remove(anchorToPlayerLineJointPin)
        self.physicsWorld.remove(playerLineToPlayerPositionJointPin)
        self.playerAttachedAnchor = nil
        self.anchorToPlayerLineJointPin = nil
        self.playerLineToPlayerPositionJointPin = nil
    }

    // MARK: - Handle player at finishing line
    private func handlePlayerAtFinishingLine() {
        hasPlayerFinishRace = true
        disableGameButtons()
    }

    private func handlePlayerAfterFinishingLine() {
        if !hasPlayerFinishRace {
            return
        }

        player?.bringToStop()
    }
}
