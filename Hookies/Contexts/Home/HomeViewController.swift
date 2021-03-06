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
    func didPressHostMatchButton(in: HomeViewController)
    func didPressJoinMatchButton(in: HomeViewController)
    func didPressFriendButton(in: HomeViewController)
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

    @IBAction private func onHostMatchClicked(_ sender: UIButton) {
        navigationDelegate?.didPressHostMatchButton(in: self)
    }

    @IBAction private func onJoinMatchClicked(_ sender: UIButton) {
        navigationDelegate?.didPressJoinMatchButton(in: self)
    }

    @IBAction private func onFriendButtonClicked(_ sender: UIButton) {
        navigationDelegate?.didPressFriendButton(in: self)
    }
}
