//
//  SocialStore.swift
//  Hookies
//
//  Created by Tan LongBin on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Firebase

class SocialStore {
    private let collection: CollectionReference

    private var socialListener: ListenerRegistration?

    init(socialCollection: CollectionReference) {
        collection = socialCollection
    }

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

    func subscribeToSocial(userId: String, listener: @escaping (Social?, Error?) -> Void) {
        let ref = collection.document(userId)
        socialListener = ref.addListener(Social.self, listener: { social, error in
            listener(social, error)
        })
    }

    func unsubscribeFromSocial() {
        socialListener?.remove()
    }

    func save(social: Social) {
        let ref = collection.document(social.documentID)
        ref.setDataModel(social)
    }
}
