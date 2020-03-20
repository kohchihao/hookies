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

    private var viewModel: PreGameLobbyViewModel

    // MARK: - PRIVATE PROPERTIES
    private let navigator: NavigatorRepresentable

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

    // TODO: Need to remove this and pass in a model that is required to start the game.
    func didPressStartButton(in: PreGameLobbyViewController, withSelectedMapType mapType: MapType) {
        let gamePlayCoordinator = GamePlayCoordinator(with: navigator, and: mapType)
        gamePlayCoordinator.coordinatorDelegate = self
        gamePlayCoordinator.start()
    }
}

extension PreGameLobbyCoordinator: MapDelegate {
    func onSelected(for map: MapType) {
        viewModel.delegate?.updateSelectedMap(mapType: map)
    }
}
