//
//  HomeViewController.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import FirebaseAuth

protocol HomeViewNavigationDelegate: class {
    func didPressLogoutButton(in: HomeViewController) throws
}

class HomeViewController: UIViewController {
    weak var navigationDelegate: HomeViewNavigationDelegate?
    private var viewModel: HomeViewModelRepresentable

    // MARK: - INIT
    init(with viewModel: HomeViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: HomeViewController.name, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as? SKView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill

                // Present the scene
                view.presentScene(scene)
            }

            view.ignoresSiblingOrder = true

            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction private func onLogoutButtonClicked(_ sender: Any) {
        do {
            try navigationDelegate?.didPressLogoutButton(in: self)
        } catch let logoutError as NSError {
            toast(message: "Error signing out: " + logoutError.localizedDescription)
        }
    }
}
