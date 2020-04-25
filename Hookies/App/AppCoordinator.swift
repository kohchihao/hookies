//
//  AppCoordinator.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import UIKit
import FirebaseAuth

class AppCoordinator: Coordinator {

    // MARK: - PROPERTIES
    var coordinators: [Coordinator] = []
    weak var coordinatorDelegate: CoordinatorDelegate?

    // MARK: - PRIVATE PROPERTIES
    private let navigator: NavigatorRepresentable

    // MARK: - INITIALIZATION
    init(with window: UIWindow, navigator: NavigatorRepresentable) {
        window.rootViewController = navigator.root()
        window.makeKeyAndVisible()
        self.navigator = navigator
        self.subscribeToAuthState()
    }

    // MARK: - FUNCTIONS
    func start() {}

    /// Will subscribe to the changes in auth state of the current user
    func subscribeToAuthState() {
        API.shared.user.subscribeToAuthStatus(listener: { authState in
            switch authState {
            case .notAuthenticated:
                self.navigateToAuth(authState)
            case .missingUsername:
                self.navigateToAuth(authState)
            case .authenticated:
                self.navigateToHome()
            }
        })
    }

    private func navigateToAuth(_ authState: AuthState) {
        let signInCoordinator = AuthCoordinator(with: navigator, authState: authState)
        signInCoordinator.coordinatorDelegate = self
        signInCoordinator.start()
    }

    private func navigateToHome() {
        let homeCoordinator = HomeCoordinator(with: navigator)
        homeCoordinator.coordinatorDelegate = self
        homeCoordinator.start()
    }
}
