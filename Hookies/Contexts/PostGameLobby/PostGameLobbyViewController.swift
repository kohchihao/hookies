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

    @IBOutlet private var continueButton: RoundButton!

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
        continueButton.isHidden = true
        self.viewModel.updateLobby()
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

    private func updatePlayerViews() {
        guard self.viewModel.players.count <= self.playerViews.count else {
            return
        }
        var index = 0
        for player in self.viewModel.players.reversed() {
            API.shared.user.get(withUid: player.playerId, completion: { user, error in
                guard error == nil else {
                    Logger.log.show(details: error.debugDescription, logType: .error)
                    return
                }
                var username: String
                if let user = user {
                    username = user.username
                } else if player.playerId.contains(Constants.botPrefix) {
                    username = String(player.playerId.prefix(Constants.botUsernameLength))
                    print(username)
                } else {
                    return
                }
                self.playerViews[index].updateUsernameLabel(username: username)
                self.playerViews[index].addPlayerImage(costumeType: player.costumeType)
                index += 1
            })
        }
    }

    @IBAction private func continueButtonPressed(_ sender: UIButton) {
        guard var lobby = self.viewModel.lobby else {
            return
        }
        guard let currentPlayerId = API.shared.user.currentUser?.uid else {
            return
        }
        if currentPlayerId == lobby.hostId {
            lobby.updateLobbyState(lobbyState: .open)
        } else {
            guard lobby.lobbyState == .open else {
                Logger.log.show(details: "Lobby is not open", logType: .error)
                return
            }
            lobby.addPlayer(playerId: currentPlayerId)
            if lobby.playersId.count >= Constants.maxPlayerCount {
                lobby.updateLobbyState(lobbyState: .full)
            }
        }
        API.shared.lobby.save(lobby: lobby)
        API.shared.lobby.unsubscribeFromLobby()
        navigationDelegate?.didPressContinueButton(in: self, lobby: lobby)
    }

    @IBAction private func returnHomeButtonPressed(_sender: UIButton) {
        API.shared.lobby.unsubscribeFromLobby()
        navigationDelegate?.didPressReturnHomeButton(in: self)
    }

    func subscribeToLobby(lobby: Lobby) {
        API.shared.lobby.subscribeToLobby(lobbyId: lobby.lobbyId, listener: { lobby, error  in
            guard error == nil else {
                Logger.log.show(details: error.debugDescription, logType: .error)
                return
            }
            guard let updatedLobby = lobby else {
                return
            }
            self.viewModel.lobby = updatedLobby
            if updatedLobby.lobbyState == .open {
                self.continueButton.isHidden = false
            }
        })
    }

    deinit {
        API.shared.lobby.unsubscribeFromLobby()
    }
}

extension PostGameLobbyViewController: PostGameLobbyViewModelDelegate {
    func lobbyLoaded(isLoaded: Bool) {
        print(self.viewModel.players)
        updatePlayerViews()
        guard let lobby = self.viewModel.lobby else {
            return
        }
        subscribeToLobby(lobby: lobby)
        guard let currentUserId = API.shared.user.currentUser?.uid else {
            return
        }
        if currentUserId == lobby.hostId {
            self.continueButton.isHidden = false
        }
    }
}
