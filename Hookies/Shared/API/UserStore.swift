//
//  User.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Firebase

class UserStore {

    private let collection: CollectionReference

    init(userCollection: CollectionReference) {
        collection = userCollection
    }

    /// Determines whether the user is signed in.
    /// There are 2 requirements for user to be signed in:
    ///     - Authenticated through firebase authentication
    ///     - Has an existing record in the firestore users collection.
    func isSignedIn(completion: @escaping (_ isSignedIn: Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            return completion(false)
        }

        API.shared.user.get(withUid: user.uid) { user, error in
            guard error == nil, user != nil else {
                return completion(false)
            }
            return completion(true)
        }
    }

    /// Get a user with the given uid.
    func get(withUid uid: String, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        let ref = collection.document(uid)
        ref.getDocumentModel(User.self) { user, error in
            guard let user = user else {
                completion(nil, error)
                return
            }
            completion(user, error)
        }
    }

    /// Attempt to create a user record with its username in firestore database.
    /// - Precondition:
    ///     - The user must be authenticated through firebase authentication
    ///     - `username` meets the `minNameLen` and `maxNameLen` criteria
    ///     - `username` in the firestore users collection, the username must be unique.
    func createAccountWithUsername(username: String,
                                   completion: @escaping (_ user: User?, _ error: UserStoreError?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return completion(nil, UserStoreError.notAuthenticated)
        }
        let minNameLen = 4
        let maxNameLen = 15

        if username.count < minNameLen {
            return completion(nil, UserStoreError.nameTooShort(minLen: minNameLen))
        }
        if username.count > maxNameLen {
            return completion(nil, UserStoreError.nameTooLong(maxLen: maxNameLen))
        }
        let user = User(uid: currentUser.uid, username: username, email: currentUser.email)
        add(user: user) { user, error in
            if let error = error {
                return completion(nil, error)
            } else {
                return completion(user, nil)
            }
        }
    }

    /// Add a entry of `user` into the users collection.
    private func add(user: User, completion: @escaping (_ user: User?,
        _ error: UserStoreError?) -> Void) {

        let ref = collection.document(user.documentID)
        collection
            .whereField("userName", isEqualTo: user.username)
            .getDocuments(completion: { result, error in
                guard error == nil, let result = result else {
                    return
                }

                if result.isEmpty {
                    ref.setDataModel(user)
                    return completion(user, nil)
                } else {
                    return completion(nil, UserStoreError.usernameExistError)
                }
        })
    }
}
