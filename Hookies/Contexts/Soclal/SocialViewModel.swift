//
//  SocialViewModel.swift
//  Hookies
//
//  Created by Tan LongBin on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import UIKit

protocol SocialViewModelRepresentable {
    var delegate: SocialViewModelDelegate? { get set }
    var social: Social { get set }
    var lobbyId: String? { get set }
    var inviteEnabled: Bool { get set }
}

class SocialViewModel: SocialViewModelRepresentable {
    weak var delegate: SocialViewModelDelegate?
    var social: Social
    var inviteEnabled: Bool
    var lobbyId: String?

    init(lobbyId: String?) {
        guard let currentUser = API.shared.user.currentUser else {
            fatalError("Host is not logged in")
        }
        self.social = Social(userId: currentUser.uid)
        self.lobbyId = lobbyId
        if lobbyId == nil {
            self.inviteEnabled = false
        } else {
            self.inviteEnabled = true
        }
    }

    init(social: Social, lobbyId: String?) {
        self.social = social
        if lobbyId == nil {
            self.inviteEnabled = false
        } else {
            self.inviteEnabled = true
        }
    }

    func updateSocial(social: Social) {
        self.social = social
    }
}

protocol SocialViewModelDelegate: class {

}
