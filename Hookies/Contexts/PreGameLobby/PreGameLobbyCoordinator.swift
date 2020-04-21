//
//  PreGameLobbyCoordinator.swift
//  Hookies
//
//  Created by Marcus Koh on 15/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class PreGameLobbyCoordinator: Coordinator {

    // MARK: - PROPERTIES
    var coordinators: [Coordinator] = []
    weak var coordinatorDelegate: CoordinatorDelegate?

    // MARK: - PRIVATE PROPERTIES
    private let navigator: NavigatorRepresentable
    private var viewModel: PreGameLobbyViewModel

    // MARK: - INIT
    init(with navigator: NavigatorRepresentable) {
        self.navigator = navigator
        self.viewModel = PreGameLobbyViewModel()
    }

    init(with navigator: NavigatorRepresentable, withLobby: Lobby) {
        self.navigator = navigator
        self.viewModel = PreGameLobbyViewModel(lobby: withLobby)
    }

    // MARK: - START
    func start() {
        coordinatorDelegate?.coordinatorDidStart(self)
        navigator.transition(to: viewController(), as: .push)
    }

    // MARK: - FUNCTIONS
    private func viewController() -> PreGameLobbyViewController {
        let viewController = PreGameLobbyViewController(with: viewModel)
        viewController.navigationDelegate = self
        return viewController
    }
}

// MARK: - PreGameLobbyViewNavigationDelegate
extension PreGameLobbyCoordinator: PreGameLobbyViewNavigationDelegate {

    func didPressSelectMapButton(in: PreGameLobbyViewController) {
        let mapsCoordinator = MapsCoordinator(with: navigator)
        mapsCoordinator.coordinatorDelegate = self
        mapsCoordinator.mapDelegate = self
        mapsCoordinator.start()
    }

    func didPressStartButton(
        in: PreGameLobbyViewController,
        withSelectedMapType mapType: MapType,
        gameplayId: String,
        players: [Player]
    ) {
        let gamePlayCoordinator = GamePlayCoordinator(
            with: navigator,
            mapType: mapType,
            gameplayId: gameplayId,
            players: players)
        gamePlayCoordinator.coordinatorDelegate = self
        gamePlayCoordinator.start()
    }

    func didPressFriendButton(in: PreGameLobbyViewController, lobbyId: String) {
        let socialCoordinator = SocialCoodinator(with: navigator, lobbyId: lobbyId)
        socialCoordinator.coordinatorDelegate = self
        socialCoordinator.start()
    }

    func didPressPostButton(in: PreGameLobbyViewController, lobbyId: String, players: [Player]) {
        let postGameLobbyCoordinator = PostGameLobbyCoordinator(with: navigator, gamePlayId: lobbyId, ranking: players)
        postGameLobbyCoordinator.coordinatorDelegate = self
        postGameLobbyCoordinator.start()
    }
}

extension PreGameLobbyCoordinator: MapDelegate {
    func onSelected(for map: MapType) {
        viewModel.delegate?.updateSelectedMap(mapType: map)
    }
}
