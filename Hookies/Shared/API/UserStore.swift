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
    private var authListener: AuthStateDidChangeListenerHandle?
    private(set) var currentUser: User?

    init(userCollection: CollectionReference) {
        collection = userCollection
    }

    /// Determines the auth status of the user
    /// There are 2 requirements for user to be signed in:
    ///     - Authenticated through firebase authentication
    ///     - Has an existing record in the firestore users collection.
    func authStatus(completion: @escaping (_: AuthState) -> Void) {
        guard let user = Auth.auth().currentUser else {
            currentUser = nil
            return completion(.notAuthenticated)
        }

        get(withUid: user.uid) { user, error in
            guard error == nil, user != nil else {
                self.currentUser = nil
                return completion(.missingUsername)
            }
            self.currentUser = user
            return completion(.authenticated)
        }
    }

    func subscribeToAuthStatus(listener: @escaping (_: AuthState) -> Void) {
        authListener = Auth.auth().addStateDidChangeListener({ auth, _  in
            guard auth.currentUser != nil else {
                self.currentUser = nil
                return listener(.notAuthenticated)
            }
            self.authStatus { state in
                listener(state)
            }
        })
    }

    func removeAuthSubscription() {
        if let authListener = authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }

    /// Get a user with the given uid.
    func get(withUid uid: String, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        let ref = collection.document(uid)
        ref.getDocumentModel(User.self) { user, error in
            guard let user = user else {
                return completion(nil, error)
            }
            return completion(user, error)
        }
    }

    /// Get a user with the given username.
    func get(withUsername username: String, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        let query = collection.whereField("username", isEqualTo: username)
        query.getModels(User.self, completion: { users, error in
           guard error == nil else {
                print(error.debugDescription)
                return completion(nil, error)
            }
            guard let user = users?.first else {
                return completion(nil, nil)
            }
            return completion(user, error)
        })
    }

    func currentUser(completion: @escaping (User?, Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return completion(nil, nil)
        }

        get(withUid: currentUser.uid) { user, error in
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
            .whereField("username", isEqualTo: user.username)
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
