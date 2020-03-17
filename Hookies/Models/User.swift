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
    private(set) var username: String
    private(set) var email: String

    init(uid: String, username: String, email: String?) {
        self.uid = uid
        self.username = username
        self.email = email ?? ""
    }
}

extension User: Hashable {
    public static func == (lhs: User, rhs: User) -> Bool {
         return lhs.uid == rhs.uid
     }

     public func hash(into hasher: inout Hasher) {
         hasher.combine(uid)
     }
}
