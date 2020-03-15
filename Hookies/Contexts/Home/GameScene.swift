//
//  GameScene.swift
//  Hookies
//
//  Created by Tan LongBin on 7/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // TODO: To remove
    let playerId = "id"
    let playerImage = "Owlet_Monster"

    private var isTouching = false
    private var player: Player?
    private var cannon: Cannon?
    private var cam: SKCameraNode?

    private var background: Background?
    private var grapplingHookButton: GrapplingHookButton?
    private var countdownLabel: SKLabelNode?
    private var count = 5

    weak var viewController: HomeViewController!

    private var powerLaunch = 1_000

    override func didMove(to view: SKView) {
        initialiseBackground(with: view.frame.size)
        initialiseGrapplingHookButton()
        initialiseCamera()

        guard let playerNode = self.childNode(withName: "//player") as? SKSpriteNode else {
                return
        }
        playerNode.removeFromParent()

        guard let cannonNode = self.childNode(withName: "//cannon") as? SKSpriteNode else {
                return
        }

        guard let playerClosestBolt = getNearestBolt(from: cannonNode.position) else {
            return
        }

        cannon = Cannon(node: cannonNode)
        player = Player(
            id: playerId,
            position: cannonNode.position,
            imageName: playerImage,
            closestBolt: playerClosestBolt
        )

        guard let player = player else {
            return
        }
        addChild(player.node)

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
//        if isTouching {
//            let moveAction = SKAction.moveBy(x: 10, y: 0, duration: 1)
//            self.player?.run(moveAction)
//        }
//        calculateNearestBolt()
        guard let player = player else {
            return
        }

        guard let playerClosestBolt = getNearestBolt(from: player.node.position) else {
            return
        }

        player.closestBolt = playerClosestBolt

        handleTetheringToBolt()
    }

    // MARK: - Initialise background

    func initialiseBackground(with size: CGSize) {
        background = Background(in: size)
        guard let background = background else {
            return
        }
        addChild(background)
    }

     // MARK: - Initialise Camera

    func initialiseCamera() {
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

    func initialiseGrapplingHookButton() {
        guard let sceneFrame = self.scene?.frame else {
            return
        }
        grapplingHookButton = GrapplingHookButton(in: sceneFrame)
    }

    // MARK: - Centering camera

    func centerOnNode(node: SKNode) {
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

    func launch() {

    }

    func setPowerLaunch(at power: Int) {
        powerLaunch = power
    }

    // MARK: - Count down to start game

    func startCountdown() {

    }

    func countdown(count: Int) {
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

    func countdownAction() {
        count -= 1
        countdownLabel?.text = "Launching player in \(count)..."
    }

    func endCountdown() {
        countdownLabel?.removeFromParent()
        viewController.hidePowerSlider()

        guard let player = player else {
            return
        }
//
        let velocity = getLaunchVelocity()
        cannon?.launch(player: player, with: velocity)
        cannon?.node.removeFromParent()
    }

    // MARK: - Calculate nearest bolt

    func getNearestBolt(from position: CGPoint) -> SKSpriteNode? {
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

        closestBolt?.isHidden = true

//        print(allBolts)

        return closestBolt
    }

    private func getLaunchVelocity() -> CGVector {
        let dx = CGFloat(powerLaunch)
        let dy = CGFloat(powerLaunch)

        return CGVector(dx: dx, dy: dy)
    }

    private func handleTetheringToBolt() {
        guard let grapplingHookButton = grapplingHookButton else {
            return
        }

        grapplingHookButton.touchBeganHandler = {
            self.player?.tetherToClosestBolt()
            guard let playerLine = self.player?.line else {
                return
            }

            self.addChild(playerLine)
        }

        if let playerLine = player?.line, player?.attachedBolt != nil {
            playerLine.removeFromParent()
            player?.updateLine()

            guard let updatedPlayerLine = player?.line else {
                return
            }
            addChild(updatedPlayerLine)
        }

        grapplingHookButton.touchEndHandler = {
            guard let playerLine = self.player?.line else {
                return
            }
            self.player?.releaseFromBolt()
            playerLine.removeFromParent()
        }
    }
}
