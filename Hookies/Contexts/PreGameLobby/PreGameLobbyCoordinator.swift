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

    private let viewModel = PreGameLobbyViewModel()

    // MARK: - PRIVATE PROPERTIES
    private let navigator: NavigatorRepresentable

    // MARK: - INIT
    init(with navigator: NavigatorRepresentable) {
        self.navigator = navigator
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
}

extension PreGameLobbyCoordinator: MapDelegate {
    func onSelected(for map: MapType) {
        viewModel.delegate?.updateSelectedMap(mapType: map)
    }
}
