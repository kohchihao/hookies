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
    func didPressStartButton(in: PreGameLobbyViewController, withSelectedMapType mapType: MapType, gameplayId: String, players: [Player])
    func didPressFriendButton(in: PreGameLobbyViewController, lobbyId: String)
    func leaveLobby()
}

class PreGameLobbyViewController: UIViewController {
    weak var navigationDelegate: PreGameLobbyViewNavigationDelegate?
    private var viewModel: PreGameLobbyViewModelRepresentable
    private var playerViews: [LobbyPlayerView] = []
    private var isOnline = true {
        didSet {
            friendsButton.isHidden = !isOnline
        }
    }
    private var startButtonHidden: Bool {
        guard let currentUser = API.shared.user.currentUser else {
            return true
        }
        return self.viewModel.lobby.hostId != currentUser.uid || viewModel.lobby.selectedMapType == nil
    }
    private var isHost: Bool {
        guard let currentUser = API.shared.user.currentUser else {
            return true
        }
        return self.viewModel.lobby.hostId == currentUser.uid
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
        NetworkManager.shared.set(gameId: self.viewModel.lobby.lobbyId)
        connectToSocket()
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
        selectMapButton.isHidden = !isHost
        addBotButton.isHidden = !isHost
    }

    private func connectToSocket() {
        API.shared.lobby.connect(roomId: self.viewModel.lobby.lobbyId, completion: { _ in })
        API.shared.lobby.subscribeToRoomConnection(roomId: self.viewModel.lobby.lobbyId, listener: { connectionState in
            switch connectionState {
            case .connected:
                self.isOnline = true
            case .disconnected:
                self.isOnline = false
            }
        })
        API.shared.lobby.subscribeToPlayersConnection(listener: { userConnection in
            switch userConnection.state {
            case .connected:
                break
            case .disconnected:
                self.viewModel.lobby.removePlayer(playerId: userConnection.uid)
                API.shared.lobby.save(lobby: self.viewModel.lobby)
                self.updateView()
            }
        })
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
                self.leaveLobby()
                return
            }
            self.viewModel.lobby = updatedLobby
            self.updateView()
            if updatedLobby.lobbyState == .empty {
                if API.shared.user.currentUser?.uid == self.viewModel.lobby.hostId {
                    API.shared.lobby.delete(lobbyId: self.viewModel.lobby.lobbyId)
                }
                self.leaveLobby()
            }
            if self.viewModel.lobby.lobbyState == .start {
                self.startGame()
            }
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        API.shared.lobby.unsubscribeFromLobby()
        API.shared.lobby.close()
    }

    deinit {
        API.shared.lobby.unsubscribeFromLobby()
        API.shared.lobby.close()
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

    private func leaveLobby() {
        navigationDelegate?.leaveLobby()
    }

    private func createGameplaySession(with lobby: Lobby) {
        let gameplay = Gameplay(gameId: lobby.lobbyId, gameState: .waiting, playersId: lobby.playersId)
        API.shared.gameplay.saveGameState(gameplay: gameplay)
    }

    // swiftlint:disable line_length

    private func createPlayers(with lobby: Lobby) -> [Player] {
        var players: [Player] = []
        guard let currentId = API.shared.user.currentUser?.uid else {
            Logger.log.show(details: "current player not found", logType: .error)
            return players
        }

        for playerId in lobby.playersId {
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
                if let player = Player(playerId: playerId, playerType: .human, costumeType: costume, isCurrentPlayer: currentId == playerId, isHost: isHost) {
                    players.append(player)
                }
            }
        }
        return players
    }

    private func updateView() {
        startGameButton.isHidden = startButtonHidden
        selectedMapLabel.text = viewModel.lobby.selectedMapType.map { $0.rawValue }
        gameSessionIdLabel.text = viewModel.lobby.lobbyId
        updatePlayerViews()
        updateCostumeIdLabel()
    }

    private func updateCostumeIdLabel() {
        guard let userId = API.shared.user.currentUser?.uid else {
            return
        }
        costumeIdLabel.text = viewModel.lobby.costumesId[userId].map({ $0.rawValue })?.replacingOccurrences(of: "_", with: " ")
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
        let playersId = self.viewModel.lobby.playersId.sorted(by: { $0 < $1 })
        guard playersId.count <= Constants.maxPlayerCount && playersId.count <= self.playerViews.count else {
            Logger.log.show(details: "max number of players exceeded", logType: .error)
            return
        }
        for playerView in playerViews {
            playerView.resetView()
        }
        var index: Int
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
    }

    private func updatePlayerViewWithUsername(playerId: String, index: Int) {
        if isOnline {
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

    @IBAction private func onReturnHomeButtonPressed(_ sender: UIButton) {
        guard let currentPlayerId = API.shared.user.currentUser?.uid else {
            return
        }
        if currentPlayerId == self.viewModel.lobby.hostId {
            self.viewModel.lobby.updateLobbyState(lobbyState: .empty)
            API.shared.lobby.save(lobby: self.viewModel.lobby)
        } else {
            self.viewModel.lobby.removePlayer(playerId: currentPlayerId)
            API.shared.lobby.save(lobby: self.viewModel.lobby)
            leaveLobby()
        }
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
