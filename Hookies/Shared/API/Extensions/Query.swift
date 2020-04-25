//
//  Query.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension Query {

    /// Gets a collection of strongly typed models from a given query.
    /// - Parameters:
    ///     - Model.Type:  The type of the model to type cast the firestore records into.
    ///     - completion: The callback handler when the function completes.
    func getModels<Model: FirestoreModel>(_: Model.Type, completion: @escaping ([Model]?, Error?) -> Void) {
        getDocuments { snapshot, error in
            self.handleCompletion(Model.self, snapshot: snapshot, error: error,
                                  completion: completion)
        }
    }

    /// Add a listener to the query
    /// - Parameters:
    ///     - Model.Type:  The type of the model to type cast the firestore records into.
    ///     - completion: The callback handler when the function completes.
    func addListener<Model: FirestoreModel>(_: Model.Type,
                                            listener: @escaping ([Model]?, Error?) -> Void) -> ListenerRegistration {
        return addSnapshotListener({ snapshot, error in
            self.handleCompletion(Model.self, snapshot: snapshot, error: error,
                                  completion: listener)
        })
    }

    private func handleCompletion<Model: FirestoreModel>(_: Model.Type,
                                                         snapshot: QuerySnapshot?,
                                                         error: Error?,
                                                         completion: @escaping ([Model]?, Error?) -> Void) {
        if let error = error {
            return completion(nil, error)
        }
        guard let snapshot = snapshot else {
            return completion(nil, nil)
        }
        completion(snapshot.documents.compactMap {
            Model(modelData: FirestoreDataModel(snapshot: $0))
        }, nil)
    }
}
