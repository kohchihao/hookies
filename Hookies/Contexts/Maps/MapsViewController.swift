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

    @IBOutlet private var mapsTableView: UITableView!

    weak var mapDelegate: MapDelegate?

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
        mapsTableView.dataSource = self
        mapsTableView.delegate = self
        mapsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LabelCell")
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension MapsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MapType.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        cell.textLabel?.text = MapType.allCases[indexPath.row].rawValue
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapDelegate?.onSelected(for: MapType.allCases[indexPath.row])
        self.dismiss(animated: false, completion: nil)
    }
}
