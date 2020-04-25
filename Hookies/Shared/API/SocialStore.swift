//
//  SocialStore.swift
//  Hookies
//
//  Created by Tan LongBin on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Firebase

/// A class that is used to interact with the backend database related to friends of the player.
class SocialStore {
    private let collection: CollectionReference

    private var socialListener: ListenerRegistration?

    init(socialCollection: CollectionReference) {
        collection = socialCollection
    }

    /// Get the social network information of the given user.
    /// - Parameters:
    ///   - userId: The id of the user.
    ///   - completion: The callback handler which gets triggered when the async function completes.
    ///                 Will return with the Social model.
    func get(userId: String, completion: @escaping (Social?, Error?) -> Void) {
        let ref = collection.document(userId)
        ref.getDocumentModel(Social.self, completion: { social, error in
            if let error = error {
                return completion(nil, error)
            }
            guard let social = social else {
                return completion(nil, nil)
            }
            completion(social, nil)
        })
    }

    /// Will subscribe to the changes to the social network information of the given user.
    /// - Parameters:
    ///   - userId: The id of the user.
    ///   - listener: The callback handler which gets triggered when the async function completes.
    ///                 Will return with the Social model.
    func subscribeToSocial(userId: String, listener: @escaping (Social?, Error?) -> Void) {
        let ref = collection.document(userId)
        socialListener = ref.addListener(Social.self, listener: { social, error in
            listener(social, error)
        })
    }

    /// Will unsubscribe to all the listeners in this class instance.
    func unsubscribeFromSocial() {
        socialListener?.remove()
    }

    /// Will save the given social model into the database.
    /// - Parameter social: The social model
    func save(social: Social) {
        let ref = collection.document(social.documentID)
        ref.setDataModel(social)
    }
}
