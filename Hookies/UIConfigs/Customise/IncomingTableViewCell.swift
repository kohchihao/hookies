//
//  RequestTableViewCell.swift
//  Hookies
//
//  Created by Tan LongBin on 3/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import UIKit

protocol IncomingTableViewCellDelegate: class {
    func acceptButtonPressed(requestId: String)
    func rejectButtonPressed(requestId: String)
    func acceptButtonPressed(inviteId: String)
    func rejectButtonPressed(inviteId: String)
}

class IncomingTableViewCell: UITableViewCell {

    weak var delegate: IncomingTableViewCellDelegate?
    var request: Request?
    var invite: Invite?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction private func acceptButtonPressed(_ sender: UIButton) {
        if let requestId = self.request?.requestId {
            delegate?.acceptButtonPressed(requestId: requestId)
        } else if let inviteId = self.invite?.inviteId {
            delegate?.acceptButtonPressed(inviteId: inviteId)
        }
    }

    @IBAction private func rejectButtonPressed(_ sender: UIButton) {
        if let requestId = self.request?.requestId {
            delegate?.rejectButtonPressed(requestId: requestId)
        } else if let inviteId = self.invite?.inviteId {
            delegate?.rejectButtonPressed(inviteId: inviteId)
        }
    }
}
