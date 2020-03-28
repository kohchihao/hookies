//
//  FirestoreModel.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import FirebaseFirestore

/// An instance of FirestoreModel would represent a model that is covertable to a document in Firestore.
protocol FirestoreModel: Encoder {
    init?(modelData: FirestoreDataModel)

    /// ID of the document in Firestore.
    var documentID: String { get }
}
