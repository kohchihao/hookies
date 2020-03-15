//
//  MapsViewController.swift
//  Hookies
//
//  Created by Marcus Koh on 15/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

protocol MapsNavigationDelegate: class {

}

class MapsViewController: UIViewController {
    weak var navigationDelegate: MapsNavigationDelegate?
    private var viewModel: MapsViewModelRepresentable

    // MARK: - INIT
    init(with viewModel: MapsViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: MapsViewController.name, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
