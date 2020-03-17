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
    var authState: AuthState
    weak var coordinatorDelegate: CoordinatorDelegate?

    // MARK: - PRIVATE PROPERTIES
    private let navigator: NavigatorRepresentable

    // MARK: - INIT
    init(with navigator: NavigatorRepresentable, authState: AuthState) {
        self.navigator = navigator
        self.authState = authState
    }

    // MARK: - START
    func start() {
        coordinatorDelegate?.coordinatorDidStart(self)
        navigator.transition(to: viewController(authState: authState), as: .push)
    }

    // MARK: - FUNCTIONS
    private func viewController(authState: AuthState) -> AuthViewController {
        let viewModel = AuthViewModel(authState: authState)
        let viewController = AuthViewController(with: viewModel)
        viewController.navigationDelegate = self
        return viewController
    }
}

// MARK: - SignInNavigationDelegate
extension AuthCoordinator: SignInNavigationDelegate {
    func didSignIn(user: User) {
        let homeCoordinator = HomeCoordinator(with: navigator)
        homeCoordinator.coordinatorDelegate = self
        homeCoordinator.start()
    }
}
