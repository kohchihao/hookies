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
    func continueGame(in: PostGameLobbyViewController, lobby: Lobby)
    func didPressReturnHomeButton(in: PostGameLobbyViewController)
}

class PostGameLobbyViewController: UIViewController {
    weak var navigationDelegate: PostGameLobbyViewNavigationDelegate?
    private var viewModel: PostGameLobbyViewModelRepresentable
    private var playerViews: [LobbyPlayerView] = []

    @IBOutlet private var continueButton: RoundButton!
    @IBOutlet private var hostStatusLabel: UILabel!

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

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: Manage Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        waitingForHost()
        setupPlayerView()
        self.viewModel.subscribeToLobby()
    }

    deinit {
        viewModel.closeLobbyConnection()
    }

    // MARK: Setup view

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

    // MARK: Update view

    private func updatePlayerViews() {
        guard self.viewModel.players.count <= self.playerViews.count else {
            return
        }
        var index = 0
        for player in self.viewModel.players {
            updatePlayerViewWithUsername(player: player, index: index)
            self.playerViews[index].addPlayerImage(costumeType: player.costumeType)
            index += 1
        }
    }

    private func updatePlayerViewWithUsername(player: Player, index: Int) {
        guard self.playerViews.indices.contains(index) else {
            return
        }
        var username: String = ""
        if player.playerId.contains(Constants.botPrefix) {
            username = String(player.playerId.prefix(Constants.botUsernameLength))
        } else if player.playerId == API.shared.user.currentUser?.uid {
            username = API.shared.user.currentUser?.username ?? ""
        }
        API.shared.user.get(withUid: player.playerId, completion: { user, error in
            guard error == nil else {
                Logger.log.show(details: error.debugDescription, logType: .error)
                return
            }
            if let user = user {
                username = user.username
            }
            self.playerViews[index].updateUsernameLabel(username: username)
            return
        })
    }

    private func waitingForHost() {
        if viewModel.isHost {
            self.continueButton.isHidden = false
            self.hostStatusLabel.isHidden = true
        } else {
            self.continueButton.isHidden = true
            self.hostStatusLabel.isHidden = false
            self.hostStatusLabel.text = "Waiting for host"
        }
    }

    // MARK: IBActions

    @IBAction private func continueButtonPressed(_ sender: UIButton) {
        viewModel.continueGame()
    }

    @IBAction private func returnHomeButtonPressed(_sender: UIButton) {
        viewModel.returnHome()
    }
}

extension PostGameLobbyViewController: PostGameLobbyViewModelDelegate {
    func updateView() {
        updatePlayerViews()
    }

    func hostHasContinued() {
        continueButton.isHidden = false
        hostStatusLabel.isHidden = true
    }

    func lobbyIsFull() {
        continueButton.isHidden = true
        hostStatusLabel.isHidden = false
        hostStatusLabel.text = "Lobby is full"
    }

    func continueGame(with lobby: Lobby) {
        navigationDelegate?.continueGame(in: self, lobby: lobby)
    }

    func leaveLobby() {
        viewModel.closeLobbyConnection()
        navigationDelegate?.didPressReturnHomeButton(in: self)
    }
}
