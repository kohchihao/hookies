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
}

class SocialViewModel: SocialViewModelRepresentable {
    weak var delegate: SocialViewModelDelegate?
    var social: Social

    init() {
        guard let currentUser = API.shared.user.currentUser else {
            fatalError("Host is not logged in")
        }
        self.social = Social(userId: currentUser.uid)
    }

    init(social: Social) {
        self.social = social
    }
}

protocol SocialViewModelDelegate: class {
    
}
