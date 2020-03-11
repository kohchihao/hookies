//
//  Coordinator.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import UIKit

protocol Coordinator: CoordinatorDelegate {

    // MARK: - PROPERTIES
    var coordinatorDelegate: CoordinatorDelegate? { get set }
    var coordinators: [Coordinator] { get set }

    // MARK: - FUNCTIONS
    func start()
}

protocol CoordinatorDelegate: class {
    func coordinatorDidStart(_ coordinator: Coordinator)
    func coordinatorDidEnd(_ coordinator: Coordinator)
}

extension Coordinator {
    func coordinatorDidStart(_ coordinator: Coordinator) {
        coordinators.append(coordinator)
    }

    func coordinatorDidEnd(_ coordinator: Coordinator) {
        coordinators = coordinators.filter { $0 !== coordinator }
    }
}
