//
//  UserModelError.swift
//  Hookies
//
//  Created by Jun Wei Koh on 1/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

enum UserModelError: Error {
    case nameTooShort(minLen: Int)
    case nameTooLong(maxLen: Int)
}

extension UserModelError: LocalizedError {
    var errorDescription: String? {
        let result = "Validation error."
        switch self {
        case .nameTooShort(let minLen):
            return "\(result) Name too short (MIN: \(minLen))"
        case .nameTooLong(let maxLen):
            return "\(result) Name too long (MAX: \(maxLen))"
        }
    }
}
