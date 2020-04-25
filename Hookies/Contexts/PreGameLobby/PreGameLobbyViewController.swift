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
    func didPressPostButton(in: PreGameLobbyViewController, lobbyId: String, players: [Player])
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
        NetworkManager.shared.set(gameId: self.viewModel.lobby.lobbyId)
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
        return players
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
            guard players.count <= Constants.maxPlayerCount && players.count <= self.playerViews.count else {
                Logger.log.show(details: "max number of players exceeded", logType: .error)
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
                    dispatch.leave()
                    return
                }
                guard let user = user else {
                    do {
                        let bot = try User(
                            uid: playerId,
                            username: String(playerId.prefix(Constants.botUsernameLength)))
                        if !players.contains(bot) {
                            players.append(bot)
                        }
                    } catch {
                        dispatch.leave()
                        return
                    }
                    dispatch.leave()
                    return
                }
                if !players.contains(user) {
                    players.append(user)
                }
                dispatch.leave()
            })
        }
        dispatch.notify(queue: .main, execute: {
            completion(players)
        })
    }

    @IBAction private func onFriendButtonPressed(_ sender: UIButton) {
        navigationDelegate?.didPressFriendButton(in: self, lobbyId: self.viewModel.lobby.lobbyId)
    }

    @IBAction private func onAddBotButtonPressed(_ sender: UIButton) {
        guard self.viewModel.lobby.playersId.count < Constants.maxPlayerCount else {
            return
        }
        let botId = "Bot" + RandomIDGenerator.getRandomID(length: 4)
        self.viewModel.lobby.addPlayer(playerId: botId)
        guard let costume = CostumeType.getRandom() else {
            return
        }
        self.viewModel.lobby.updateCostumeId(playerId: botId, costumeType: costume)
        API.shared.lobby.save(lobby: self.viewModel.lobby)
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
