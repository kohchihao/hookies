//
//  OutgoingRequestTableViewCell.swift
//  Hookies
//
//  Created by Tan LongBin on 3/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import UIKit

protocol OutgoingTableViewCellDelegate: class {
    func cancelButtonPressed(requestId: String)
    func cancelButtonPressed(inviteId: String)
}

class OutgoingTableViewCell: UITableViewCell {

    weak var delegate: OutgoingTableViewCellDelegate?
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

    @IBAction private func cancelButtonPressed(_ sender: UIButton) {
        if let requestId = self.request?.requestId {
            delegate?.cancelButtonPressed(requestId: requestId)
        } else if let inviteId = self.invite?.inviteId {
            delegate?.cancelButtonPressed(inviteId: inviteId)
        }
    }
}
