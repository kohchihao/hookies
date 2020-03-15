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
    private func viewController() -> GamePlayViewController {
       let viewModel = GamePlayViewModel()
       let viewController = GamePlayViewController(with: viewModel)
       viewController.navigationDelegate = self
       return viewController
    }
}

// MARK: - GameViewNavigationDelegate
extension GamePlayCoordinator: GameViewNavigationDelegate {

}
