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
    var delegate: SignInViewModelDelegate? { get set }

    func createAccountWithUsername(username: String,
                                   completion: @escaping (_ user: User?, _ error: LocalizedError?) -> Void)
    func cleanup()
}

class AuthViewModel: AuthViewModelRepresentable {
    weak var delegate: SignInViewModelDelegate?
    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        authListener = Auth.auth().addStateDidChangeListener { _, user in
            guard user != nil else {
                return
            }
            API.shared.user.isSignedIn(completion: { isSignIn in
                self.delegate?.toPromptForUsername(toPrompt: isSignIn)
            })
        }
    }

    func cleanup() {
        if let authListener = self.authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }

    func createAccountWithUsername(username: String,
                                   completion: @escaping (_ user: User?, _ error: LocalizedError?) -> Void) {
        API.shared.user.createAccountWithUsername(username: username) { user, error in
            if let error = error {
                completion(nil, error)
            }
            completion(user, nil)
        }

    }
}

protocol SignInViewModelDelegate: class {
    func toPromptForUsername(toPrompt: Bool)
}
