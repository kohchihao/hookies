//
//  Navigator.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import UIKit

protocol NavigatorRepresentable {
    func root() -> UINavigationController
    func transition(to viewController: UIViewController, as type: NavigatorTransitionType)
    func dismiss()
    func pop()
}

/// The navigator that manages the transition between view controllers.

struct Navigator: NavigatorRepresentable {

    // MARK: - PRIVATE PROPERTIES
    private var navigationController: UINavigationController

    // MARK: - INITIALIZATION
    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - PUBLIC NAVIGATION FUNCTIONS

    /// Returns the root navigation controller
    func root() -> UINavigationController {
        return navigationController
    }

    /// Transition between different controllers.
    /// - Parameters:
    ///   - viewController: The view controller to transition to.
    ///   - type: The type of navigation
    func transition(to viewController: UIViewController, as type: NavigatorTransitionType) {
        switch type {
        case .root:
            navigationController.viewControllers = [viewController]
        case .push:
            navigationController.pushViewController(viewController, animated: true)
        case .modal:
            navigationController.present(viewController, animated: true, completion: nil)
        }
    }

    /// Dismiss the navigation controller.
    func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }

    /// Pop the view controller.
    func pop() {
        navigationController.popViewController(animated: true)
    }
}
