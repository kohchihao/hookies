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
    func didPressStartButton(in: PreGameLobbyViewController, withSelectedMapType mapType: MapType)
}

class PreGameLobbyViewController: UIViewController {
    weak var navigationDelegate: PreGameLobbyViewNavigationDelegate?
    private var viewModel: PreGameLobbyViewModelRepresentable
    private var playersIdDispatchGroup = DispatchGroup()
    private var players: [User] = []
    private var playerViews: [LobbyPlayerView] = []

    @IBOutlet private var selectedMapLabel: UILabel!
    @IBOutlet private var gameSessionIdLabel: UILabel!
    @IBOutlet private var playersIdLabel: UILabel!
    @IBOutlet private var player1View: LobbyPlayerView!
    @IBOutlet private var player2View: LobbyPlayerView!
    @IBOutlet private var player3View: LobbyPlayerView!
    @IBOutlet private var player4View: LobbyPlayerView!
    
    // MARK: - INIT
    init(with viewModel: PreGameLobbyViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: PreGameLobbyViewController.name, bundle: nil)
        saveLobby(lobby: viewModel.lobby)
        subscribeToLobby(lobby: viewModel.lobby)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        playerViews.append(player1View)
        playerViews.append(player2View)
        playerViews.append(player3View)
        playerViews.append(player4View)
        updateView()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func saveLobby(lobby: Lobby) {
        API.shared.lobby.save(lobby: lobby)
    }

    func subscribeToLobby(lobby: Lobby) {
        API.shared.lobby.subscribeToLobby(lobbyId: lobby.lobbyId, listener: { lobby, error  in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            guard let updatedLobby = lobby else {
                return
            }
            self.viewModel.lobby = updatedLobby
            self.updateView()
        })
    }

    deinit {
        API.shared.lobby.unsubscribeFromLobby()
    }

    @IBAction private func onSelectMapClicked(_ sender: UIButton) {
        navigationDelegate?.didPressSelectMapButton(in: self)
    }

    @IBAction private func onStartClicked(_ sender: UIButton) {
        guard let selectedMap = viewModel.selectedMap else {
            return
        }
        navigationDelegate?.didPressStartButton(in: self, withSelectedMapType: selectedMap)
    }

    private func updateView() {
        gameSessionIdLabel.text = viewModel.lobby.lobbyId
        for playerId in viewModel.lobby.playersId {
            getPlayer(playerId: playerId)
        }
        playersIdDispatchGroup.notify(queue: DispatchQueue.main) {
            if self.players.count == self.viewModel.lobby.playersId.count {
                self.updatePlayerViews()
            }
        }
    }

    private func updatePlayerViews() {
        for i in 0..<min(4, self.players.count) {
            playerViews[i].updateUsernameLabel(username: players[i].username)
            guard let costumeType = viewModel.lobby.costumesId[players[i].uid] else {
                return
            }
            playerViews[i].addPlayerImage(costumeType: costumeType)
        }
    }

    private func getPlayer(playerId: String) {
        playersIdDispatchGroup.enter()
        API.shared.user.get(withUid: playerId, completion: { user, error in
            guard error == nil else {
                return
            }
            guard let user = user else {
                return
            }
            if !self.players.contains(user) {
                self.players.append(user)
            }
            self.playersIdDispatchGroup.leave()
        })
    }
}

extension PreGameLobbyViewController: RoomStateViewModelDelegate {
    func updateSelectedMap(mapType: MapType) {
        viewModel.selectedMap = mapType
        selectedMapLabel.text = mapType.rawValue
    }

    func updateLobbyViewModel(lobbyViewModel: PreGameLobbyViewModelRepresentable) {
        self.viewModel = lobbyViewModel
    }
}
