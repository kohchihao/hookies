//
//  UserStoreError.swift
//  Hookies
//
//  Created by Jun Wei Koh on 11/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

enum UserStoreError: Error {
    case usernameExistError
    case notAuthenticated
}

extension UserStoreError: LocalizedError {
    var errorDescription: String? {
        let result = "Failed to create account."
        switch self {
        case .usernameExistError:
            return "\(result) Username is already taken"
        case .notAuthenticated:
            return "\(result) You must be authenticated first"
        }
    }
}
