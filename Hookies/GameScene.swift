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

    override func didMove(to view: SKView) {
        initialiseBackground(with: view.frame.size)
        initialiseGrapplingHookButton()
        initialiseCamera()

        self.player = self.childNode(withName: "//player") as? SKSpriteNode
        self.player?.zPosition = 2
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
            let moveAction = SKAction.moveBy(x: 10, y:0, duration: 1)
            self.player?.run(moveAction)

        }
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
        let action = SKAction.move(to: CGPoint(x:node.position.x , y:0 ), duration: 0.5)
        self.cam?.run(action)
        self.background?.run(action)
    }

    override func didFinishUpdate() {
        guard let player = player else {
            return
        }
        centerOnNode(node: player)
    }


}
