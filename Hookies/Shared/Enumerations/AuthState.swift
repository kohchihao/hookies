//
//  AuthState.swift
//  Hookies
//
//  Created by Jun Wei Koh on 17/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

/// Represent the authentication state of a user
enum AuthState {
    case notAuthenticated, missingUsername, authenticated
}
