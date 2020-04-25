//
//  Coordinator.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import UIKit

/// A Coordinator has the responsibility to navigate between screens.
protocol Coordinator: CoordinatorDelegate {

    // MARK: - PROPERTIES
    var coordinatorDelegate: CoordinatorDelegate? { get set }
    var coordinators: [Coordinator] { get set }

    // MARK: - FUNCTIONS

    /// Will navigate to the different screen here.
    func start()
}

protocol CoordinatorDelegate: class {
    /// To be called when the coordinator is started.
    /// And used to inform the delegate that the give coodinator has started
    /// - Parameter coordinator: The coordinator that started
    func coordinatorDidStart(_ coordinator: Coordinator)
    /// To be called when the coordinator is ended.
    /// And used to inform the delegate that the give coodinator has ended
    /// - Parameter coordinator: The coordinator that ended
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
