//
//  PreGameLobbyViewController.swift
//  Hookies
//
//  Created by Marcus Koh on 15/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

protocol PreGameLobbyViewNavigationDelegate: class {
    func didPressSelectMapButton(in: PreGameLobbyViewController)
}

class PreGameLobbyViewController: UIViewController {
    weak var navigationDelegate: PreGameLobbyViewNavigationDelegate?
    private var viewModel: PreGameLobbyViewModelRepresentable

    // MARK: - INIT
    init(with viewModel: PreGameLobbyViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: PreGameLobbyViewController.name, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction private func onSelectMapClicked(_ sender: UIButton) {
        navigationDelegate?.didPressSelectMapButton(in: self)
    }
}
