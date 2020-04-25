//
//  AuthViewModel.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import FirebaseAuth

protocol AuthViewModelRepresentable {
    var toPromptForUsername: Bool { get }

    func createAccountWithUsername(username: String,
                                   completion: @escaping (_ user: User?, _ error: LocalizedError?) -> Void)
}

class AuthViewModel: AuthViewModelRepresentable {
    private(set) var toPromptForUsername: Bool

    init(authState: AuthState) {
        toPromptForUsername = (authState == .missingUsername)
    }

    /// Will create account for the current player with the defined username
    /// - Parameters:
    ///   - username: The username of the current player
    ///   - completion: The callback handler that gets triggered when the account creation is done.
    func createAccountWithUsername(username: String,
                                   completion: @escaping (User?, LocalizedError?) -> Void) {
        API.shared.user.createAccountWithUsername(username: username) { user, error in
            if let error = error {
                completion(nil, error)
            }
            completion(user, nil)
        }
    }
}
