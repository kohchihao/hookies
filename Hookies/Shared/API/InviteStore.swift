//
//  InviteStore.swift
//  Hookies
//
//  Created by Tan LongBin on 4/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Firebase

/// A class that is used to provide the backend API for  invitation into the game lobby.
class InviteStore {
    private let collection: CollectionReference

    init(inviteCollection: CollectionReference) {
        self.collection = inviteCollection
    }


    /// Will get the invite of the given invite Id, if any.
    /// - Parameters:
    ///   - inviteId: The id of the invite
    ///   - completion: The callback handler when the async request completes.
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

    /// Will save the lobby invites into the backend database.
    /// - Parameters:
    ///   - invite: The lobby invitation model
    func save(invite: Invite) {
        let ref = collection.document(invite.documentID)
        ref.setDataModel(invite)
    }


    /// Will delete the lobby invitation that is on the backend database.
    /// - Parameter invite: The lobby invitation model
    func delete(invite: Invite) {
        let ref = collection.document(invite.documentID)
        ref.delete(completion: { error in
            if let error = error {
                Logger.log.show(details: "Error removing the document: \(error)", logType: .error)
            }
        })
    }
}
