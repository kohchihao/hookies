//
//  User.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

struct User {
    private(set) var uid: String
    private(set) var userName: String
    private(set) var email: String

    init(uid: String, userName: String, email: String?) {
        self.uid = uid
        self.userName = userName
        self.email = email ?? ""
    }
}
