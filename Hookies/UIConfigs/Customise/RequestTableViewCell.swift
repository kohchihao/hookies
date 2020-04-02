//
//  RequestTableViewCell.swift
//  Hookies
//
//  Created by Tan LongBin on 3/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import UIKit

protocol RequestTableViewCellDelegate: class {
    func acceptButtonPressed(requestId: String)
    func rejectButtonPressed(requestId: String)
}

class RequestTableViewCell: UITableViewCell {

    weak var delegate: RequestTableViewCellDelegate?
    var request: Request?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction private func acceptButtonPressed(_ sender: UIButton) {
        guard let requestId = self.request?.requestId else {
            return
        }
        delegate?.acceptButtonPressed(requestId: requestId)
    }

    @IBAction private func rejectButtonPressed(_ sender: UIButton) {
        guard let requestId = self.request?.requestId else {
            return
        }
        delegate?.rejectButtonPressed(requestId: requestId)
    }
}
