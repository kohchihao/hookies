//
//  SocialCoordinator.swift
//  Hookies
//
//  Created by Tan LongBin on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class SocialCoodinator: Coordinator {

    var coordinators: [Coordinator] = []
    weak var coordinatorDelegate: CoordinatorDelegate?

    private var viewModel: SocialViewModel

    private let navigator: NavigatorRepresentable

    init(with navigator: NavigatorRepresentable) {
        self.navigator = navigator
        self.viewModel = SocialViewModel()
    }

    func start() {
        coordinatorDelegate?.coordinatorDidStart(self)
        navigator.transition(to: viewController(), as: .push)
    }

    private func viewController() -> SocialViewController {
        let viewController = SocialViewController(with: viewModel)
        viewController.navigationDelegate = self
        return viewController
    }
}

extension SocialCoodinator: SocialViewNavigationDelegate {

}
