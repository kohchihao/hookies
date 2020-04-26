//
//  SocialCoordinator.swift
//  Hookies
//
//  Created by Tan LongBin on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class SocialCoodinator: Coordinator {

    // MARK: - PROPERTIES
    var coordinators: [Coordinator] = []
    weak var coordinatorDelegate: CoordinatorDelegate?

    // MARK: - PRIVATE PROPERTIES
    private var viewModel: SocialViewModel
    private let navigator: NavigatorRepresentable

    // MARK: - INIT
    init(with navigator: NavigatorRepresentable) {
        self.navigator = navigator
        self.viewModel = SocialViewModel(lobbyId: nil)
    }

    init(with navigator: NavigatorRepresentable, lobbyId: String) {
        self.navigator = navigator
        self.viewModel = SocialViewModel(lobbyId: lobbyId)
    }

    init(with navigator: NavigatorRepresentable, viewModel: SocialViewModel) {
        self.navigator = navigator
        self.viewModel = viewModel
    }

    // MARK: - START
    func start() {
        coordinatorDelegate?.coordinatorDidStart(self)
        navigator.transition(to: viewController(), as: .modal)
    }

    // MARK: - FUNCTIONS
    private func viewController() -> SocialViewController {
        let viewController = SocialViewController(with: viewModel)
        viewController.navigationDelegate = self
        return viewController
    }
}

// MARK: - SocialViewNavigationDelegate
extension SocialCoodinator: SocialViewNavigationDelegate {
    func didAcceptInvite(invite: Invite) {
        API.shared.lobby.get(lobbyId: invite.lobbyId, completion: { lobby, error in
            guard error == nil else {
                Logger.log.show(details: error.debugDescription, logType: .error)
                return
            }
            guard var lobby = lobby else {
                Logger.log.show(details: "Lobby not found", logType: .error)
                return
            }
            guard let playerId = API.shared.user.currentUser?.uid else {
                Logger.log.show(details: "user is not logged in", logType: .error)
                return
            }
            guard lobby.lobbyState == .open else {
                Logger.log.show(details: "lobby is not open", logType: .error).display(.toast)
                return
            }
            lobby.addPlayer(playerId: playerId)
            let preGameLobbyCoordinator = PreGameLobbyCoordinator(with: self.navigator, withLobby: lobby)
            preGameLobbyCoordinator.coordinatorDelegate = self
            preGameLobbyCoordinator.start()
        })
    }
}
