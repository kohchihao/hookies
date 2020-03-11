//
//  SignInCoordinator.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class SignInCoordinator: Coordinator {

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
    private func viewController() -> SignInViewController {
       let viewModel = SignInViewModel()
       let viewController = SignInViewController(with: viewModel)
       viewController.navigationDelegate = self
       return viewController
    }
}

// MARK: - HomeViewNavigationDelegate
extension SignInCoordinator: SignInNavigationDelegate {
    func didSignIn(user: User) {
        let homeCoordinator = HomeCoordinator(with: navigator)
        homeCoordinator.coordinatorDelegate = self
        homeCoordinator.start()
    }
}
