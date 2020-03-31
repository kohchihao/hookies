//
//  LobbyPlayerView.swift
//  Hookies
//
//  Created by Tan LongBin on 21/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import UIKit

class LobbyPlayerView: UIView {

    @IBOutlet private var mainView: UIView!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var usernameLabelBg: UIImageView!
    @IBOutlet private var playerPodium: UIImageView!
    @IBOutlet private var playerImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("LobbyPlayerView", owner: self, options: nil)
        addSubview(mainView)
        mainView.frame = self.bounds
    }

    func updateUsernameLabel(username: String) {
        usernameLabel.text = username
    }

    func addPlayerImage(costumeType: CostumeType) {
        guard let image = UIImage(named: costumeType.rawValue) else {
            return
        }
        playerImageView.image = image
    }
}
