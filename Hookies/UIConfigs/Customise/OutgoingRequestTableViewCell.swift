//
//  OutgoingRequestTableViewCell.swift
//  Hookies
//
//  Created by Tan LongBin on 3/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import UIKit

protocol OutgoingRequestTableViewCellDelegate: class {
    func cancelButtonPressed(requestId: String)
}

class OutgoingRequestTableViewCell: UITableViewCell {

    weak var delegate: OutgoingRequestTableViewCellDelegate?
    var request: Request?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction private func cancelButtonPressed(_ sender: UIButton) {
        guard let requestId = self.request?.requestId else {
            return
        }
        delegate?.cancelButtonPressed(requestId: requestId)
    }
}
