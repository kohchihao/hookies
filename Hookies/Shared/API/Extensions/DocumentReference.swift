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
    func setDataModel(_ model: FirestoreModel) {
        var documentData = [String: Any]()

        for (key, value) in model.encoding {
            if key == "documentID" {
                continue
            }

            documentData[key] = value
        }

        setData(documentData)
    }

    /// Get a strongly typed casted model of a Firestore document.
    /// - Parameters:
    ///     - Model.Type:  The type of the model to type cast the firestore records into.
    ///     - completion: The callback handler when the function completes.
    func getDocumentModel<Model: FirestoreModel>(_: Model.Type,
                                                 completion: @escaping (Model?, Error?) -> Void) {
        getDocument { snapshot, error in
            self.handleCompletion(Model.self, snapshot: snapshot, error: error,
                                  completion: completion)
        }
    }

    /// Add a listener to the model.
    /// Whenever there is an update to the firestore of the given model, the listener will be activated.
    func addListener<Model: FirestoreModel>(_: Model.Type,
                                            listener: @escaping (Model?, Error?) -> Void) -> ListenerRegistration {
        return addSnapshotListener { snapshot, error in
            self.handleCompletion(Model.self, snapshot: snapshot, error: error,
                                  completion: listener)
        }
    }

    private func handleCompletion<Model: FirestoreModel>(_: Model.Type,
                                                         snapshot: DocumentSnapshot?,
                                                         error: Error?,
                                                         completion: @escaping (Model?, Error?) -> Void) {
        if let error = error {
            return completion(nil, error)
        }
        guard let snapshot = snapshot else {
            return completion(nil, nil)
        }
        completion(Model(modelData: FirestoreDataModel(snapshot: snapshot)), nil)
    }
}
