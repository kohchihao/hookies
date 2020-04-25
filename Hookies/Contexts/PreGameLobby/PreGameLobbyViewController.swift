//
//  PreGameLobbyViewController.swift
//  Hookies
//
//  Created by Marcus Koh on 15/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit

protocol PreGameLobbyViewNavigationDelegate: class {
    func didPressSelectMapButton(in: PreGameLobbyViewController)
    func didPressStartButton(
        in: PreGameLobbyViewController,
        withSelectedMapType mapType: MapType,
        gameplayId: String,
        players: [Player])
    func didPressFriendButton(in: PreGameLobbyViewController, lobbyId: String)
    func leaveLobby()
}

class PreGameLobbyViewController: UIViewController {
    weak var navigationDelegate: PreGameLobbyViewNavigationDelegate?
    private var viewModel: PreGameLobbyViewModelRepresentable
    private var playerViews: [LobbyPlayerView] = []
    private var startButtonHidden: Bool {
        return self.viewModel.lobby.hostId != API.shared.user.currentUser?.uid || self.viewModel.lobby.selectedMapType == nil
    }

    @IBOutlet private var selectedMapLabel: UILabel!
    @IBOutlet private var gameSessionIdLabel: UILabel!
    @IBOutlet private var costumeIdLabel: UILabel!
    @IBOutlet private var startGameButton: UIButton!
    @IBOutlet private var selectMapButton: UIButton!
    @IBOutlet private var friendsButton: UIButton!
    @IBOutlet private var addBotButton: UIButton!

    // MARK: - INIT
    init(with viewModel: PreGameLobbyViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: PreGameLobbyViewController.name, bundle: nil)
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
        setupPlayerView()
        viewModel.delegate = self
        selectMapButton.isHidden = !viewModel.isHost
        addBotButton.isHidden = !viewModel.isHost
        updateView()
    }

    deinit {
        viewModel.closeLobbyConnection()
    }

    // MARK: Setup View

    private func setupPlayerView() {
        guard Constants.maxPlayerCount > 0 else {
            return
        }
        self.playerViews = []
        let width = self.view.frame.width / CGFloat(Constants.maxPlayerCount)
        let height = width * 1.2
        for i in 1...Constants.maxPlayerCount {
            let x = width * CGFloat(i - 1)
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
                Logger.log.show(details: error.debugDescription, logType: .error)
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
        let players = createPlayers(with: viewModel.lobby)
        API.shared.lobby.unsubscribeFromLobby()
        navigationDelegate?.didPressStartButton(
            in: self,
            withSelectedMapType: selectedMapType,
            gameplayId: viewModel.lobby.lobbyId, players: players)
    }

    private func createGameplaySession(with lobby: Lobby) {
        let gameplay = Gameplay(gameId: lobby.lobbyId, gameState: .waiting, playersId: lobby.playersId)
        API.shared.gameplay.saveGameState(gameplay: gameplay)
    }

    private func createPlayers(with lobby: Lobby) -> [Player] {
        var players: [Player] = []
        guard let currentId = API.shared.user.currentUser?.uid else {
            Logger.log.show(details: "current player not found", logType: .error)
            return players
        }
        let hostId = lobby.hostId
        guard let hostCostume = lobby.costumesId[lobby.hostId] ?? CostumeType.getDefault() else {
            return players
        }
        guard let host = Player(
            playerId: hostId,
            playerType: .human,
            costumeType: hostCostume,
            isCurrentPlayer: currentId == hostId,
            isHost: true
            ) else {
            return players
        }
        players.append(host)

        for playerId in lobby.playersId.filter({ $0 != lobby.hostId }) {
            guard let costume = lobby.costumesId[playerId] ?? CostumeType.getDefault() else {
                continue
            }
            if playerId.contains(Constants.botPrefix) {
                guard let botType = BotType.getRandom() else {
                    continue
                }
                if let bot = Player(playerId: playerId, playerType: .bot, costumeType: costume, botType: botType) {
                    players.append(bot)
                }
            } else {
                if let player = Player(
                    playerId: playerId,
                    playerType: .human,
                    costumeType: costume,
                    isCurrentPlayer: currentId == playerId,
                    isHost: false
                    ) {
                    players.append(player)
                }
            }
        }
    }

    // MARK: Update View

    private func updateCostumeIdLabel() {
        guard let userId = API.shared.user.currentUser?.uid else {
            return
        }
        costumeIdLabel.text = viewModel.lobby.costumesId[userId].map({ $0.rawValue })?.replacingOccurrences(of: "_", with: " ")
    }

    private func updatePlayerViewWithUsername(playerId: String, index: Int) {
        if viewModel.isOnline {
            API.shared.user.get(withUid: playerId, completion: { user, error in
                guard error == nil else {
                   Logger.log.show(details: error.debugDescription, logType: .error)
                   return
                }
                var username: String = ""
                if let user = user {
                    username = user.username
                } else if playerId.contains(Constants.botPrefix) {
                    username = String(playerId.prefix(Constants.botUsernameLength))
                }
                self.playerViews[index].updateUsernameLabel(username: username)
            })
        } else {
            var username: String = "Current Offline"
            if playerId == API.shared.user.currentUser?.uid {
                username = API.shared.user.currentUser?.username ?? "Currently Offline"
            } else if playerId.contains(Constants.botPrefix) {
                username = String(playerId.prefix(Constants.botUsernameLength))
            }
            self.playerViews[index].updateUsernameLabel(username: username)
        }
    }

    private func updatePlayerViews() {
        let playersId = self.viewModel.lobby.playersId.sorted(by: { $0 < $1 })
        guard playersId.count <= Constants.maxPlayerCount && playersId.count <= self.playerViews.count else {
            Logger.log.show(details: "max number of players exceeded", logType: .error)
            return
        }
        var index: Int = 0
        var otherPlayersViewIndex = 1
        for playerId in self.viewModel.lobby.playersId {
            if playerId == self.viewModel.lobby.hostId {
                index = 0
            } else {
                index = otherPlayersViewIndex
                otherPlayersViewIndex += 1
            }

            guard let costumeType = self.viewModel.lobby.costumesId[playerId] else {
                return
            }
            updatePlayerViewWithUsername(playerId: playerId, index: index)
            self.playerViews[index].addPlayerImage(costumeType: costumeType)
        }
        index += 1
        if self.playerViews.indices.contains(index) {
            for unusedIndex in self.playerViews.indices[index...] {
                self.playerViews[unusedIndex].resetView()
            }
        }
    }

    // MARK: IBActions
    
    @IBAction private func onSelectMapClicked(_ sender: UIButton) {
        navigationDelegate?.didPressSelectMapButton(in: self)
    }

    @IBAction private func onStartClicked(_ sender: UIButton) {
        viewModel.prepareGame()
    }

    @IBAction private func nextCostume() {
        viewModel.nextCostume()
    }

    @IBAction private func prevCostume() {
        viewModel.prevCostume()
    }

    @IBAction private func onFriendButtonPressed(_ sender: UIButton) {
        navigationDelegate?.didPressFriendButton(in: self, lobbyId: self.viewModel.lobby.lobbyId)
    }

    @IBAction private func onAddBotButtonPressed(_ sender: UIButton) {
        viewModel.addBot()
    }

    @IBAction private func onReturnHomeButtonPressed(_ sender: UIButton) {
        viewModel.leaveLobby()
    }
}

extension PreGameLobbyViewController: RoomStateViewModelDelegate {
    func startGame(with players: [Player]) {
        guard let selectedMapType = viewModel.lobby.selectedMapType else {
            Logger.log.show(details: "Map not selected.", logType: .error)
            return
        }
        viewModel.closeLobbyConnection()
        navigationDelegate?.didPressStartButton(
            in: self,
            withSelectedMapType: selectedMapType,
            gameplayId: viewModel.lobby.lobbyId, players: players)
    }

    func updateView() {
        startGameButton.isHidden = startButtonHidden
        selectedMapLabel.text = viewModel.lobby.selectedMapType.map { $0.rawValue }
        gameSessionIdLabel.text = viewModel.lobby.lobbyId
        updatePlayerViews()
        updateCostumeIdLabel()
    }

    func leaveLobby() {
        viewModel.closeLobbyConnection()
        navigationDelegate?.leaveLobby()
    }
}
