//
//  RequestStore.swift
//  Hookies
//
//  Created by Tan LongBin on 1/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Firebase

class RequestStore {
    private let collection: CollectionReference

    init(requestCollection: CollectionReference) {
        self.collection = requestCollection
    }

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

    func save(request: Request) {
        let ref = collection.document(request.documentID)
        ref.setDataModel(request)
    }

    func delete(request: Request) {
        let ref = collection.document(request.documentID)
        ref.delete(completion: { error in
            if let error = error {
                print("Error removing the document: \(error)")
            }
        })
    }
}
