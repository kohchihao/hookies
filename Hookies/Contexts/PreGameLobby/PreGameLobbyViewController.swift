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
    func didPressFriendButton(in: PreGameLobbyViewController)
}

class PreGameLobbyViewController: UIViewController {
    weak var navigationDelegate: PreGameLobbyViewNavigationDelegate?
    private var viewModel: PreGameLobbyViewModelRepresentable
    private var playerViews: [LobbyPlayerView] = []
    private var startButtonEnabled: Bool {
        guard let currentUser = API.shared.user.currentUser else {
            return false
        }
        return self.viewModel.lobby.hostId == currentUser.uid && viewModel.lobby.selectedMapType != nil
    }
    private var selectMapEnabled: Bool {
        guard let currentUser = API.shared.user.currentUser else {
            return false
        }
        return self.viewModel.lobby.hostId == currentUser.uid
    }

    @IBOutlet private var selectedMapLabel: UILabel!
    @IBOutlet private var gameSessionIdLabel: UILabel!
    @IBOutlet private var costumeIdLabel: UILabel!
    @IBOutlet private var startGameButton: UIButton!
    @IBOutlet private var socialView: UIView!
    @IBOutlet private var selectMapButton: UIButton!

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
        setupPlayerView()
        viewModel.delegate = self
        saveLobby(lobby: viewModel.lobby)
        subscribeToLobby(lobby: viewModel.lobby)
        selectMapButton.isEnabled = selectMapEnabled
    }

    private func setupPlayerView() {
        self.playerViews = []
        let width = self.view.frame.width / CGFloat(Constants.maxPlayerCount)
        let height = width * 1.2
        for i in 0...Constants.maxPlayerCount {
            let x = width * CGFloat(i)
            let y = self.view.frame.height - height * 1.2
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
    }

    private func setUpSocialView() {
        let socialViewModel = SocialViewModel(lobbyId: self.viewModel.lobby.lobbyId)
        let socialViewController = SocialViewController(with: socialViewModel)
        self.addChild(socialViewController)
        self.socialView.addSubview(socialViewController.view)
        socialViewController.didMove(toParent: self)
        socialViewController.view.translatesAutoresizingMaskIntoConstraints = false
        let margins = socialView.layoutMarginsGuide
        socialViewController.view.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        socialViewController.view.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        socialViewController.view.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        socialViewController.view.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        socialView.isHidden = true
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
        saveLobby(lobby: viewModel.lobby)
    }

    private func startGame() {
        guard let selectedMapType = viewModel.lobby.selectedMapType else {
            return
        }
        guard viewModel.lobby.lobbyState == .start else {
            return
        }
        saveLobby(lobby: viewModel.lobby)
        createGameplaySession(with: viewModel.lobby)
        navigationDelegate?.didPressStartButton(
            in: self,
            withSelectedMapType: selectedMapType,
            gameplayId: viewModel.lobby.lobbyId)
    }

    private func createGameplaySession(with lobby: Lobby) {
        let gameplay = Gameplay(gameId: lobby.lobbyId, gameState: .waiting, playersId: lobby.playersId)
        API.shared.gameplay.saveGameState(gameplay: gameplay)
    }

    private func updateView() {
        startGameButton.isEnabled = startButtonEnabled
        selectedMapLabel.text = viewModel.lobby.selectedMapType.map { $0.rawValue }
        gameSessionIdLabel.text = viewModel.lobby.lobbyId
        updatePlayerViews()
        updateCostumeIdLabel()
    }

    private func updateCostumeIdLabel() {
        guard let userId = API.shared.user.currentUser?.uid else {
            return
        }
        costumeIdLabel.text = viewModel.lobby.costumesId[userId].map { $0.rawValue }
    }

    @IBAction private func nextCostume() {
        guard let userId = API.shared.user.currentUser?.uid else {
            return
        }
        let currentCostume = viewModel.lobby.costumesId[userId]
        guard let nextCostume = CostumeType.nextCostume(currentCostume: currentCostume) else {
            return
        }
        viewModel.lobby.updateCostumeId(playerId: userId, costumeType: nextCostume)
        updateCostumeIdLabel()
        updatePlayerViews()
        saveLobby(lobby: viewModel.lobby)
    }

    @IBAction private func prevCostume() {
        guard let userId = API.shared.user.currentUser?.uid else {
            return
        }
        let currentCostume = viewModel.lobby.costumesId[userId]
        guard let prevCostume = CostumeType.prevCostume(currentCostume: currentCostume) else {
            return
        }
        viewModel.lobby.updateCostumeId(playerId: userId, costumeType: prevCostume)
        updateCostumeIdLabel()
        updatePlayerViews()
        saveLobby(lobby: viewModel.lobby)
    }

    private func updatePlayerViews() {
        getPlayers(playersId: self.viewModel.lobby.playersId, completion: { players in
            var players = players
            players.sort(by: { $0.username < $1.username })
            guard players.count <= Constants.maxPlayerCount else {
                print("max number of players exceeded")
                return
            }
            var otherPlayersViewIndex = 1
            var index: Int
            for player in players {
                if player.uid == self.viewModel.lobby.hostId {
                    index = 0
                } else {
                    index = otherPlayersViewIndex
                    otherPlayersViewIndex += 1
                }
                self.playerViews[index].updateUsernameLabel(username: player.username)
                guard let costumeType = self.viewModel.lobby.costumesId[player.uid] else {
                    return
                }
                self.playerViews[index].addPlayerImage(costumeType: costumeType)
            }
        })
    }

    private func getPlayers(playersId: [String], completion: @escaping ([User]) -> Void) {
        let dispatch = DispatchGroup()
        var players: [User] = []
        for playerId in playersId {
            dispatch.enter()
            API.shared.user.get(withUid: playerId, completion: { user, error in
                guard error == nil else {
                    return
                }
                guard let user = user else {
                    return
                }
                if !players.contains(user) {
                    players.append(user)
                }
                dispatch.leave()
            })
        }
        dispatch.notify(queue: .main, execute: {
            return completion(players)
        })
    }

    @IBAction private func onFriendButtonPressed(_ sender: UIButton) {
        navigationDelegate?.didPressFriendButton(in: self)
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
