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

    // MARK: - INIT
    init(with navigator: NavigatorRepresentable, and mapType: MapType) {
        self.navigator = navigator
        self.mapType = mapType
    }

    // MARK: - START
    func start() {
        coordinatorDelegate?.coordinatorDidStart(self)
        navigator.transition(to: viewController(), as: .push)
    }

    // MARK: - FUNCTIONS
    private func viewController() -> GamePlayViewController {
        let viewModel = GamePlayViewModel(withSelectedMap: mapType)
        let viewController = GamePlayViewController(with: viewModel)
        viewController.navigationDelegate = self
        return viewController
    }
}

// MARK: - GameViewNavigationDelegate
extension GamePlayCoordinator: GameViewNavigationDelegate {

}
