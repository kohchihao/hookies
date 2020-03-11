//
//  DocumentReference.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension DocumentReference {
    /// Set the given model to the firestore document.
    /// If the document already exist on firestore, will update it.
    /// If the document does not exist, a document will be inserted.
    func setModel(_ model: FirestoreModel) {
        var documentData = [String: Any]()

        for (key, value) in model.serialized {
            if key == "documentID" {
                continue
            }

            documentData[key] = value
        }

        setData(documentData)
    }

    /// Get a strongly typed casted model of a Firestore document.
    func getModel<Model: FirestoreModel>(_: Model.Type, completion: @escaping (Model?, Error?) -> Void) {
        getDocument { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let snapshot = snapshot else {
                completion(nil, nil)
                return
            }

            completion(Model(modelData: FirestoreModelData(snapshot: snapshot)), nil)
        }
    }
}
