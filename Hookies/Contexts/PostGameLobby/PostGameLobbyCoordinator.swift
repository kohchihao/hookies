//
//  PostGameLobbyCoordinator.swift
//  Hookies
//
//  Created by Tan LongBin on 21/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class PostGameLobbyCoordinator: Coordinator {

    // MARK: - PROPERTIES
    var coordinators: [Coordinator] = []
    weak var coordinatorDelegate: CoordinatorDelegate?

    // MARK: - PRIVATE PROPERTIES
    private let navigator: NavigatorRepresentable
    private var viewModel: PostGameLobbyViewModel

    // MARK: - INIT
    init(with navigator: NavigatorRepresentable, gamePlayId: String, ranking: [Player]) {
        self.navigator = navigator
        self.viewModel = PostGameLobbyViewModel(lobbyId: gamePlayId, players: ranking)
    }

    // MARK: - START
    func start() {
        coordinatorDelegate?.coordinatorDidStart(self)
        navigator.transition(to: viewController(), as: .push)
    }

    // MARK: - FUNCTIONS
    private func viewController() -> PostGameLobbyViewController {
        let viewController = PostGameLobbyViewController(with: viewModel)
        viewController.navigationDelegate = self
        return viewController
    }
}

// MARK: - PostGameLobbyViewNavigationDelegate
extension PostGameLobbyCoordinator: PostGameLobbyViewNavigationDelegate {
    func continueGame(in: PostGameLobbyViewController, lobby: Lobby) {
        let preGameLobbyCoordinator = PreGameLobbyCoordinator(with: navigator, withLobby: lobby)
        preGameLobbyCoordinator.coordinatorDelegate = self
        preGameLobbyCoordinator.start()
    }

    func didPressReturnHomeButton(in: PostGameLobbyViewController) {
        let homeCoordinator = HomeCoordinator(with: navigator)
        homeCoordinator.coordinatorDelegate = self
        homeCoordinator.start()
    }
}
