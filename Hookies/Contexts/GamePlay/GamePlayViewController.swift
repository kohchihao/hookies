//
//  GameViewController.swift
//  Hookies
//
//  Created by Marcus Koh on 15/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

protocol GameViewNavigationDelegate: class {
    func gameDidEnd(gamePlayId: String, rankings: [Player])
}

class GamePlayViewController: UIViewController {
    weak var navigationDelegate: GameViewNavigationDelegate?
    private var viewModel: GamePlayViewModelRepresentable

    private var gameScene: GameScene?
    @IBOutlet private var powerSlider: UISlider!

    // MARK: - INIT
    init(with viewModel: GamePlayViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: GamePlayViewController.name, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isMultipleTouchEnabled = true
        if let view = self.view as? SKView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: viewModel.selectedMap.rawValue) {
                scene.players = viewModel.players

                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill

                // Present the scene
                view.presentScene(scene)
                gameScene = scene
                gameScene?.viewController = self
            }

            view.ignoresSiblingOrder = true

            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    func endGame(rankings: [Player]) {
        navigationDelegate?.gameDidEnd(gamePlayId: viewModel.gameplayId, rankings: rankings)
        self.removeFromParent()
        self.dismiss(animated: true, completion: nil)
        if let view = self.view as? SKView {
            view.presentScene(nil)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction private func onPowerSliderChanged(_ sender: UISlider) {
        gameScene?.setPowerLaunch(at: Int(sender.value))
    }

    func hidePowerSlider() {
        powerSlider.isHidden = true
    }

    func unhidePowerSlider() {
        powerSlider.isHidden = false
    }
}
