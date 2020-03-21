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
    func didPressStartButton(in: PreGameLobbyViewController, withSelectedMapType mapType: MapType, gameplayId: String)
}

class PreGameLobbyViewController: UIViewController {
    weak var navigationDelegate: PreGameLobbyViewNavigationDelegate?
    private var viewModel: PreGameLobbyViewModelRepresentable
    private var playersIdDispatchGroup = DispatchGroup()
    private var currentUserDispatchGroup = DispatchGroup()
    private var players: [User] = []
    private var playerViews: [LobbyPlayerView] = []
    private var currentUser: User?
    private var startButtonEnabled: Bool {
        guard let currentUser = self.currentUser else {
            return false
        }
        return self.viewModel.lobby.hostId == currentUser.uid && viewModel.lobby.selectedMapType != nil
    }

    @IBOutlet private var selectedMapLabel: UILabel!
    @IBOutlet private var gameSessionIdLabel: UILabel!
    @IBOutlet private var playersIdLabel: UILabel!
    @IBOutlet private var player1View: LobbyPlayerView!
    @IBOutlet private var player2View: LobbyPlayerView!
    @IBOutlet private var player3View: LobbyPlayerView!
    @IBOutlet private var player4View: LobbyPlayerView!
    @IBOutlet private var costumeIdLabel: UILabel!
    @IBOutlet private var startGameButton: UIButton!

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
        getCurrentUser()
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
            if self.viewModel.lobby.lobbyState == .start {
                self.startGame()
            }
        })
    }

    deinit {
        API.shared.lobby.unsubscribeFromLobby()
    }

    @IBAction private func onSelectMapClicked(_ sender: UIButton) {
        navigationDelegate?.didPressSelectMapButton(in: self)
    }

    @IBAction private func onStartClicked(_ sender: UIButton) {
        viewModel.lobby.updateLobbyState(lobbyState: .start)
        startGame()
    }

    private func startGame() {
        guard let selectedMapType = viewModel.lobby.selectedMapType else {
            return
        }
        guard viewModel.lobby.lobbyState == .start else {
            return
        }
        createGameplaySession(with: viewModel.lobby)
        navigationDelegate?.didPressStartButton(in: self, withSelectedMapType: selectedMapType, gameplayId: viewModel.lobby.lobbyId)
    }

    private func createGameplaySession(with lobby: Lobby) {
        let gameplay = Gameplay(gameId: lobby.lobbyId, gameState: .waiting, playersId: lobby.playersId)
        API.shared.gameplay.saveGameState(gameplay: gameplay)
    }

    private func updateView() {
        startGameButton.isEnabled = startButtonEnabled
        gameSessionIdLabel.text = viewModel.lobby.lobbyId
        for playerId in viewModel.lobby.playersId {
            getPlayer(playerId: playerId)
        }
        playersIdDispatchGroup.notify(queue: DispatchQueue.main) {
            if self.players.count == self.viewModel.lobby.playersId.count {
                self.updatePlayerViews()
            }
        }
        currentUserDispatchGroup.notify(queue: DispatchQueue.main) {
            if self.currentUser != nil {
                self.updateCostumeIdLabel()
            }
        }
    }

    private func updateCostumeIdLabel() {
        guard let userId = currentUser?.uid else {
            return
        }
        costumeIdLabel.text = viewModel.lobby.costumesId[userId].map { $0.rawValue }
    }

    @IBAction private func nextCostume() {
        guard let userId = currentUser?.uid else {
            return
        }
        let currentCostume = viewModel.lobby.costumesId[userId]
        switch currentCostume {
        case .Pink_Monster:
            viewModel.lobby.updateCostumeId(playerId: userId, costumeType: .Owlet_Monster)
        case .Owlet_Monster:
            viewModel.lobby.updateCostumeId(playerId: userId, costumeType: .Dude_Monster)
        case .Dude_Monster:
            viewModel.lobby.updateCostumeId(playerId: userId, costumeType: .Pink_Monster)
        default:
            return
        }
        updateCostumeIdLabel()
        updatePlayerViews()
        saveLobby(lobby: viewModel.lobby)
    }

    @IBAction private func prevCostume() {
        guard let userId = currentUser?.uid else {
            return
        }
        let currentCostume = viewModel.lobby.costumesId[userId]
        switch currentCostume {
        case .Pink_Monster:
            viewModel.lobby.updateCostumeId(playerId: userId, costumeType: .Dude_Monster)
        case .Owlet_Monster:
            viewModel.lobby.updateCostumeId(playerId: userId, costumeType: .Pink_Monster)
        case .Dude_Monster:
            viewModel.lobby.updateCostumeId(playerId: userId, costumeType: .Owlet_Monster)
        default:
            return
        }
        updateCostumeIdLabel()
        updatePlayerViews()
        saveLobby(lobby: viewModel.lobby)
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

    private func getCurrentUser() {
        currentUserDispatchGroup.enter()
        API.shared.user.currentUser(completion: { user, error in
            guard error == nil else {
                return
            }
            self.currentUser = user
            self.currentUserDispatchGroup.leave()
        })
    }
}

extension PreGameLobbyViewController: RoomStateViewModelDelegate {
    func updateSelectedMap(mapType: MapType) {
        viewModel.updateSelectedMapType(selectedMapType: mapType)
        selectedMapLabel.text = mapType.rawValue
        saveLobby(lobby: viewModel.lobby)
    }

    func updateLobbyViewModel(lobbyViewModel: PreGameLobbyViewModelRepresentable) {
        self.viewModel = lobbyViewModel
        saveLobby(lobby: viewModel.lobby)
    }
}
