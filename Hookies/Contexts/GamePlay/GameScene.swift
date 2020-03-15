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

    private var isTouching = false
    private var player: SKSpriteNode?
    private var cam: SKCameraNode?

    private var background: Background?
    private var grapplingHookButton: GrapplingHookButton?
    private var countdownLabel: SKLabelNode?
    private var count = 5

    weak var viewController: GamePlayViewController!

    private var powerLaunch = 50

    override func didMove(to view: SKView) {
        initialiseBackground(with: view.frame.size)
        initialiseGrapplingHookButton()
        initialiseCamera()

        self.player = self.childNode(withName: "//player") as? SKSpriteNode
        self.player?.zPosition = 2

        countdown(count: count)
        calculateNearestBolt()
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
        if isTouching {
            let moveAction = SKAction.moveBy(x: 10, y: 0, duration: 1)
            self.player?.run(moveAction)
        }
        calculateNearestBolt()
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
        guard let grapplingHookButton = grapplingHookButton else {
            return
        }
        grapplingHookButton.selectedHandler = {
            print("Hello")
        }
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
        centerOnNode(node: player)
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

        run(SKAction.sequence([SKAction.repeat(counterDecrement, count: 5), SKAction.run(endCountdown)]))

    }

    func countdownAction() {
        count -= 1
        countdownLabel?.text = "Launching player in \(count)..."
    }

    func endCountdown() {
        countdownLabel?.removeFromParent()
        viewController.hidePowerSlider()
    }

    // MARK: - Calculate nearest bolt

    func calculateNearestBolt() {
        let allBolts = self["bolt"] // getting all the bolts within the scene.
        guard let player = player else {
            return
        }
        let playerPosition = player.position
        var closestBolt: SKSpriteNode?
        var closestDistance = Double.greatestFiniteMagnitude
        for bolt in allBolts {
            let boltPosition = bolt.position
            let distanceX = boltPosition.x - playerPosition.x
            let distanceY = boltPosition.y - playerPosition.y
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
    }
}
