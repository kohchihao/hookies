//
//  SignInViewModel.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import FirebaseAuth

protocol SignInViewModelRepresentable {
    var delegate: SignInViewModelDelegate? { get set }
    func createAccountWithUsername(username: String,
                                   completion: @escaping (_ user: User?, _ error: LocalizedError?) -> Void)
}

class SignInViewModel: SignInViewModelRepresentable {
    weak var delegate: SignInViewModelDelegate?

    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            guard user != nil else {
                return
            }
            API.shared.user.isSignedIn(completion: { isSignIn in
                self.delegate?.toPromptForUsername(isSignedIn: isSignIn)
            })
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
    func toPromptForUsername(isSignedIn: Bool)
}
