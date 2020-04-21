//
//  GameCoordinator.swift
//  Hookies
//
//  Created by Marcus Koh on 15/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class GamePlayCoordinator: Coordinator {

    // MARK: - PROPERTIES
    var coordinators: [Coordinator] = []
    weak var coordinatorDelegate: CoordinatorDelegate?

    // MARK: - PRIVATE PROPERTIES
    private let navigator: NavigatorRepresentable
    private let mapType: MapType
    private let gameplayId: String
    private let players: [Player]

    // MARK: - INIT
    init(with navigator: NavigatorRepresentable, mapType: MapType, gameplayId: String, players: [Player]) {
        self.navigator = navigator
        self.mapType = mapType
        self.gameplayId = gameplayId
        self.players = players
    }

    // MARK: - START
    func start() {
        coordinatorDelegate?.coordinatorDidStart(self)
        navigator.transition(to: viewController(), as: .push)
    }

    // MARK: - FUNCTIONS
    private func viewController() -> GamePlayViewController {
        let viewModel = GamePlayViewModel(withSelectedMap: mapType, and: gameplayId, players: players)
        let viewController = GamePlayViewController(with: viewModel)
        viewController.navigationDelegate = self
        return viewController
    }
}

// MARK: - GameViewNavigationDelegate
extension GamePlayCoordinator: GameViewNavigationDelegate {
    func gameDidEnd(gamePlayId: String, rankings: [Player]) {
        // TODO: Create Post Lobby Coordinator
    }
}
