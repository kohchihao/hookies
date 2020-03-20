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

    @IBOutlet private var selectedMapLabel: UILabel!
    @IBOutlet private var gameSessionIdLabel: UILabel!
    @IBOutlet private var playersIdLabel: UILabel!

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
        preparePlayers()
    }

    private func preparePlayers() {
        playersIdLabel.text = viewModel.lobby.hostId
//        playersIdLabel.text?.append(viewModel.lobby.hostId)
//        for playerId in viewModel.lobby.playersId {
//            playersIdLabel.text?.append(playerId)
//            playersIdLabel.text?.append("\n")
//        }
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
