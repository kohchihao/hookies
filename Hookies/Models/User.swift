//
//  User.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

struct User {
    static let minNameLen = 4
    static let maxNameLen = 15

    private(set) var uid: String
    private(set) var username: String

    init(uid: String, username: String) throws {
        if username.count < User.minNameLen {
            throw UserModelError.nameTooShort(minLen: User.minNameLen)
        }
        if username.count > User.maxNameLen {
            throw UserModelError.nameTooLong(maxLen: User.maxNameLen)
        }

        self.uid = uid
        self.username = username
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
