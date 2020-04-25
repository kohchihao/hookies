//
//  RequestStore.swift
//  Hookies
//
//  Created by Tan LongBin on 1/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Firebase

/// A class that is used to interact with the backend database related to friend requests.
class RequestStore {
    private let collection: CollectionReference

    init(requestCollection: CollectionReference) {
        self.collection = requestCollection
    }

    /// Get the friend request with the given request id.
    /// - Parameters:
    ///   - requestId: The Id of the friend request.
    ///   - completion: The callback handler which gets triggered when the async function completes.
    ///                 Will return with the Request model.
    func get(requestId: String, completion: @escaping (Request?, Error?) -> Void) {
        let ref = collection.document(requestId)
        ref.getDocumentModel(Request.self, completion: { request, error in
            if let error = error {
                return completion(nil, error)
            }
            guard let request = request else {
                return completion(nil, nil)
            }
            completion(request, nil)
        })
    }

    /// Will save the given request onto the backend database
    /// - Parameter request: The friend request model.
    func save(request: Request) {
        let ref = collection.document(request.documentID)
        ref.setDataModel(request)
    }

    /// Will delete the friend request on the backend database.
    /// - Parameter request: The friend request model.
    func delete(request: Request) {
        let ref = collection.document(request.documentID)
        ref.delete(completion: { error in
            if let error = error {
                Logger.log.show(details: "Error removing the document: \(error)", logType: .error)
            }
        })
    }
}
