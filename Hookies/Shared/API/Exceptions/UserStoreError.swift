//
//  UserStoreError.swift
//  Hookies
//
//  Created by Jun Wei Koh on 11/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

enum UserStoreError: Error {
    case userNameExistError
    case notAuthenticated
    case nameTooShort(minLen: Int)
    case nameTooLong(maxLen: Int)
}

extension UserStoreError: LocalizedError {
    var errorDescription: String? {
        let result = "Failed to create account."
        switch self {
        case .userNameExistError:
            return "\(result) Username is already taken"
        case .notAuthenticated:
            return "\(result) You must be authenticated first"
        case .nameTooShort(let minLen):
            return "\(result) Name too short (MIN: \(minLen))"
        case .nameTooLong(let maxLen):
            return "\(result) Name too long (MAX: \(maxLen))"
        }
    }
}
