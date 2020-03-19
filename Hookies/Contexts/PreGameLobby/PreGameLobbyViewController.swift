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
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        gameSessionIdLabel.text = viewModel.lobby.lobbyId
        preparePlayers()
    }

    override var prefersStatusBarHidden: Bool {
        return true
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

    private func preparePlayers() {
        for playerId in viewModel.lobby.playersId {
            playersIdLabel.text?.append(playerId)
            playersIdLabel.text?.append("\n")
        }
    }
}

extension PreGameLobbyViewController: RoomStateViewModelDelegate {
    func updateSelectedMap(mapType: MapType) {
        viewModel.selectedMap = mapType
        selectedMapLabel.text = mapType.rawValue
    }
}
