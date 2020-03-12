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
            if let error = error {
                completion(nil, error)
                return
            }

            guard let snapshot = snapshot else {
                completion(nil, nil)
                return
            }

            completion(snapshot.documents.compactMap {
                Model(modelData: FirestoreModelData(snapshot: $0))
            }, nil)
        }
    }
}
