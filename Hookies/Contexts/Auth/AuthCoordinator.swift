//
//  AuthCoordinator.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class AuthCoordinator: Coordinator {

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
    private func viewController() -> AuthViewController {
       let viewModel = AuthViewModel()
       let viewController = AuthViewController(with: viewModel)
       viewController.navigationDelegate = self
       return viewController
    }
}

// MARK: - HomeViewNavigationDelegate
extension AuthCoordinator: SignInNavigationDelegate {
    func didSignIn(user: User) {
        let homeCoordinator = HomeCoordinator(with: navigator)
        homeCoordinator.coordinatorDelegate = self
        homeCoordinator.start()
    }
}
