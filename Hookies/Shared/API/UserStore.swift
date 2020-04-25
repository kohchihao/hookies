//
//  User.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Firebase

/// A class that is used to interact with the backend database related to operations on the current user.
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

    /// Will subscrbe to changes of auth status of the current player.
    /// - Parameter listener: The callback handler which gets triggered when the async function completes.
    ///                       Will return with the AuthState model.
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

    /// Get a user with the given uid.
    /// - Parameters:
    ///   - uid: The uid of the user
    ///   - completion: The callback handler which gets triggered when the async function completes.
    ///                 The with the User model.
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
    /// - Parameters:
    ///   - username: The username of the user
    ///   - completion: The callback handler which gets triggered when the async function completes.
    ///                 Will return with the User model.
    func get(withUsername username: String, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        let query = collection.whereField("username", isEqualTo: username)
        query.getModels(User.self, completion: { users, error in
           guard error == nil else {
                Logger.log.show(details: error.debugDescription, logType: .error)
                return completion(nil, error)
            }
            guard let user = users?.first else {
                return completion(nil, nil)
            }
            return completion(user, error)
        })
    }

    /// Will get the current user.
    /// - Parameter completion: The callback handler which gets triggered when the async function completes.
    ///                         The with the User model.
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
                                   completion: @escaping (_ user: User?, _ error: LocalizedError?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return completion(nil, UserStoreError.notAuthenticated)
        }

        do {
            let user = try User(uid: currentUser.uid, username: username)
            add(user: user) { user, error in
                if let error = error {
                    return completion(nil, error)
                } else {
                    return completion(user, nil)
                }
            }
        } catch {
            return completion(nil, error as? LocalizedError)
        }
    }

    /// Add a entry of `user` into the users collection.
    /// - Parameters:
    ///   - user: The user model to add
    ///   - completion: The callback handler which gets triggered when the async function completes.
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
                    self.currentUser = user
                    return completion(user, nil)
                } else {
                    return completion(nil, UserStoreError.usernameExistError)
                }
        })
    }
}
