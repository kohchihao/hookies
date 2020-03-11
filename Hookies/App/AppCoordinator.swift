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
    }

    // MARK: - FUNCTIONS
    func start() {
        API.shared.user.isSignedIn(completion: { isSignedIn in
            if isSignedIn {
                self.navigateToHome()
            } else {
                self.navigateToSignIn()
            }
        })
    }

    func navigateToSignIn() {
        let signInCoordinator = SignInCoordinator(with: navigator)
        signInCoordinator.coordinatorDelegate = self
        signInCoordinator.start()
    }

    func navigateToHome() {
        let homeCoordinator = HomeCoordinator(with: navigator)
        homeCoordinator.coordinatorDelegate = self
        homeCoordinator.start()
    }
}
