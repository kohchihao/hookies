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

struct Navigator: NavigatorRepresentable {

    // MARK: - PRIVATE PROPERTIES
    private var navigationController: UINavigationController

    // MARK: - INITIALIZATION
    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - PUBLIC NAVIGATION FUNCTIONS
    func root() -> UINavigationController {
        return navigationController
    }

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

    func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }

    func pop() {
        navigationController.popViewController(animated: true)
    }
}
