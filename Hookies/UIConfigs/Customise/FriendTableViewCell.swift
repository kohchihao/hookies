//
//  FriendTableViewCell.swift
//  Hookies
//
//  Created by Tan LongBin on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import UIKit

protocol FriendTableViewCellDelegate: class {
    func deleteButtonPressed(username: String)
    func inviteButtonPressed(username: String)
}

class FriendTableViewCell: UITableViewCell {

    weak var delegate: FriendTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction private func deleteButtonPressed(_ sender: UIButton) {
        guard let username = self.textLabel?.text else {
            return
        }
        delegate?.deleteButtonPressed(username: username)
    }

    func hideInviteButton() {
//        inviteButton.isHidden = true
    }

    func showInviteButton() {
//        inviteButton.isHidden = false
    }

    @IBAction private func inviteButtonPressed(_ sender: UIButton) {
        guard let username = self.textLabel?.text else {
            return
        }
        delegate?.inviteButtonPressed(username: username)
    }
}
