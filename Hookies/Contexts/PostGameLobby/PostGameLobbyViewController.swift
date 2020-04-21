//
//  PostGameLobbyViewController.swift
//  Hookies
//
//  Created by Tan LongBin on 21/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import UIKit

protocol PostGameLobbyViewNavigationDelegate: class {
    func didPressContinueButton(in: PostGameLobbyViewController, lobby: Lobby)
    func didPressReturnHomeButton(in: PostGameLobbyViewController)
}

class PostGameLobbyViewController: UIViewController {
    weak var navigationDelegate: PostGameLobbyViewNavigationDelegate?
    private var viewModel: PostGameLobbyViewModelRepresentable
    private var playerViews: [LobbyPlayerView] = []
    private var continueButtonEnabled: Bool {
        self.viewModel.lobby != nil
    }
    @IBOutlet var continueButton: RoundButton!

    // MARK: - INIT
    init(with viewModel: PostGameLobbyViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: PostGameLobbyViewController.name, bundle: nil)
        self.viewModel.delegate = self
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.isEnabled = continueButtonEnabled
        setupPlayerView()
    }

    private func setupPlayerView() {
        guard Constants.maxPlayerCount > 0 else {
            return
        }
        self.playerViews = []
        let width = self.view.frame.width / CGFloat(Constants.maxPlayerCount)
        let height = width * 1.2
        func addPlayerView(x: CGFloat, y: CGFloat) {
            let frame = CGRect(x: x, y: y, width: width, height: height)
            let playerView = LobbyPlayerView(frame: frame)
            self.view.addSubview(playerView)
            self.playerViews.append(playerView)

            playerView.mainView.translatesAutoresizingMaskIntoConstraints = false
            let margins = playerView.layoutMarginsGuide
            playerView.mainView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
            playerView.mainView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
            playerView.mainView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
            playerView.mainView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        }
        for i in 1...Constants.maxPlayerCount {
            switch i {
            case 1:
                let x = width
                let y = self.view.frame.height - CGFloat(i) * height - height * 1.2
                addPlayerView(x: x, y: y)
                continue
            case 2:
                let x: CGFloat = 0
                let y = self.view.frame.height - 0.5 * height - height * 1.2
                addPlayerView(x: x, y: y)
                continue
            default:
                let x = width * CGFloat(i - 1)
                let y = self.view.frame.height - height * 1.2
                addPlayerView(x: x, y: y)
                continue
            }
        }
    }

    @IBAction private func continueButtonPressed(_ sender: UIButton) {
        guard let lobby = self.viewModel.lobby else {
            return
        }
        print(lobby)
        navigationDelegate?.didPressContinueButton(in: self, lobby: lobby)
    }

    @IBAction private func returnHomeButtonPressed(_sender: UIButton) {
        navigationDelegate?.didPressReturnHomeButton(in: self)
    }
}

extension PostGameLobbyViewController: PostGameLobbyViewModelDelegate {
    func lobbyLoaded(isLoaded: Bool) {
        self.continueButton.isEnabled = isLoaded
    }
}
