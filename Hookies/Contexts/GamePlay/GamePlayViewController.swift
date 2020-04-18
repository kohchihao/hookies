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
    // TODO: Add Ranking of Players
    func gameDidEnd(gamePlayId: String)
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

        if let view = self.view as? SKView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: viewModel.selectedMap.rawValue) {
                scene.gameplayId = viewModel.gameplayId
//                scene.players = viewMode.players

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

    func endGame() {
        navigationDelegate?.gameDidEnd(gamePlayId: viewModel.gameplayId)
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
