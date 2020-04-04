//
//  SocialCoordinator.swift
//  Hookies
//
//  Created by Tan LongBin on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class SocialCoodinator: Coordinator {

    var coordinators: [Coordinator] = []
    weak var coordinatorDelegate: CoordinatorDelegate?

    private var viewModel: SocialViewModel

    private let navigator: NavigatorRepresentable

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

    func start() {
        coordinatorDelegate?.coordinatorDidStart(self)
        navigator.transition(to: viewController(), as: .modal)
    }

    private func viewController() -> SocialViewController {
        let viewController = SocialViewController(with: viewModel)
        viewController.navigationDelegate = self
        return viewController
    }
}

extension SocialCoodinator: SocialViewNavigationDelegate {
    func didAcceptInvite(invite: Invite) {
        API.shared.lobby.get(lobbyId: invite.lobbyId, completion: { lobby, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            guard var lobby = lobby else {
                print("Lobby not found")
                return
            }
            guard let playerId = API.shared.user.currentUser?.uid else {
                print("user is not logged in")
                return
            }
            guard lobby.lobbyState == .open else {
                print("lobby is not open")
                return
            }
            lobby.addPlayer(playerId: playerId)
            let preGameLobbyCoordinator = PreGameLobbyCoordinator(with: self.navigator, withLobby: lobby)
            preGameLobbyCoordinator.coordinatorDelegate = self
            preGameLobbyCoordinator.start()
        })
    }
}
