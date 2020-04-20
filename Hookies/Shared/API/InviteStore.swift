//
//  InviteStore.swift
//  Hookies
//
//  Created by Tan LongBin on 4/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Firebase

class InviteStore {
    private let collection: CollectionReference

    init(inviteCollection: CollectionReference) {
        self.collection = inviteCollection
    }

    func get(inviteId: String, completion: @escaping (Invite?, Error?) -> Void) {
        let ref = collection.document(inviteId)
        ref.getDocumentModel(Invite.self, completion: { invite, error in
            if let error = error {
                return completion(nil, error)
            }
            guard let invite = invite else {
                return completion(nil, nil)
            }
            completion(invite, nil)
        })
    }

    func save(invite: Invite) {
        let ref = collection.document(invite.documentID)
        ref.setDataModel(invite)
    }

    func delete(invite: Invite) {
        let ref = collection.document(invite.documentID)
        ref.delete(completion: { error in
            if let error = error {
                Logger.log.show(details: "Error removing the document: \(error)", logType: .error)
            }
        })
    }
}
