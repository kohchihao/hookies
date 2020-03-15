//
//  MapsCoordinator.swift
//  Hookies
//
//  Created by Marcus Koh on 15/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class MapsCoordinator: Coordinator {

    // MARK: - PROPERTIES
    var coordinators: [Coordinator] = []
    weak var coordinatorDelegate: CoordinatorDelegate?
    weak var mapDelegate: MapDelegate?

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
    private func viewController() -> MapsViewController {
        let viewModel = MapsViewModel()
        let viewController = MapsViewController(with: viewModel)
        viewController.navigationDelegate = self
        viewController.mapDelegate = mapDelegate
        return viewController
    }
}

// MARK: - MapsNavigationDelegate
extension MapsCoordinator: MapsNavigationDelegate {

}
