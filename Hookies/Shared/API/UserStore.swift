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

    func get(withUid uid: String, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        let ref = collection.document(uid)
        ref.getModel(User.self) { user, error in
            guard let user = user else {
                completion(nil, error)
                return
            }
            completion(user, error)
        }
    }

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
        let user = User(uid: currentUser.uid, userName: username, email: currentUser.email)
        add(user: user) { user, error in
            if let error = error {
                return completion(nil, error)
            } else {
                return completion(user, nil)
            }
        }
    }

    private func add(user: User, completion: @escaping (_ user: User?,
        _ error: UserStoreError?) -> Void) {

        let ref = collection.document(user.documentID)
        collection
            .whereField("userName", isEqualTo: user.userName)
            .getDocuments(completion: { result, error in
                guard error == nil, let result = result else {
                    return
                }

                if result.isEmpty {
                    ref.setModel(user)
                    return completion(user, nil)
                } else {
                    return completion(nil, UserStoreError.userNameExistError)
                }
        })
    }
}
