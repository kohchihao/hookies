//
//  JoinGameCoordinator.swift
//  Hookies
//
//  Created by Tan LongBin on 19/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class JoinGameCoordinator: Coordinator {

    // MARK: - PROPERTIES
    var coordinators: [Coordinator] = []
    weak var coordinatorDelegate: CoordinatorDelegate?

    private let viewModel = JoinGameViewModel()

    // MARK: - PRIVATE PROPERTIES
    private let navigator: NavigatorRepresentable

    // MARK: - INIT
    init(with navigator: NavigatorRepresentable) {
        self.navigator = navigator
    }

    // MARK: - START
    func start() {
        coordinatorDelegate?.coordinatorDidStart(self)
        navigator.transition(to: viewController(), as: .modal)
    }

    // MARK: - FUNCTIONS
    private func viewController() -> JoinGameViewController {
        let viewController = JoinGameViewController(with: viewModel)
        viewController.navigationDelegate = self
        return viewController
    }
}

// MARK: - JoinGameViewNavigationDelegate
extension JoinGameCoordinator: JoinGameViewNavigationDelegate {
    func didPressJoinLobbyButton(in: JoinGameViewController, lobbyId: String) {
        API.shared.lobby.get(lobbyId: lobbyId, completion: { lobby, error in
            guard error == nil else {
                Logger.log.show(details: error.debugDescription, logType: .error)
                return
            }
            guard var lobby = lobby else {
                return
            }
            guard let playerId = API.shared.user.currentUser?.uid else {
                return
            }
            guard lobby.lobbyState == .open else {
                return
            }
            lobby.addPlayer(playerId: playerId)
            let preGameLobbyCoordinator = PreGameLobbyCoordinator(with: self.navigator, withLobby: lobby)
            preGameLobbyCoordinator.coordinatorDelegate = self
            preGameLobbyCoordinator.start()
        })
    }
}
