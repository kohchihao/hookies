//
//  HomeCoordinator.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit

class HomeCoordinator: Coordinator {

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
    private func viewController() -> HomeViewController {
        let viewModel = HomeViewModel()
        let viewController = HomeViewController(with: viewModel)
        viewController.navigationDelegate = self
        return viewController
    }
}

// MARK: - HomeViewNavigationDelegate
extension HomeCoordinator: HomeViewNavigationDelegate {
    func didPressLogoutButton(in: HomeViewController) throws {
        try Auth.auth().signOut()
        let signInCoordinator = AuthCoordinator(with: navigator)
        signInCoordinator.coordinatorDelegate = self
        signInCoordinator.start()
    }
}
