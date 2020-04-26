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
        return self.viewModel.lobby.hostId != API.shared.user.currentUser?.uid
            || self.viewModel.lobby.selectedMapType == nil
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

    // MARK: Update View
    private func updateCostumeIdLabel() {
        guard let userId = API.shared.user.currentUser?.uid else {
            return
        }
        costumeIdLabel.text = viewModel.lobby.costumesId[userId].map({
            $0.rawValue })?.replacingOccurrences(of: "_", with: " ")
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

// MARK: PreGameLobbyViewModelDelegate
extension PreGameLobbyViewController: PreGameLobbyViewModelDelegate {
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
