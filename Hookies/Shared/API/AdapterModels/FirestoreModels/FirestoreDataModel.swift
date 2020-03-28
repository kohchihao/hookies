//
//  FirestoreDataModel.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// A model that is used to wrap around a snapshot of data from FIrestore.
struct FirestoreDataModel: Decoder {

    let snapshot: DocumentSnapshot

    var documentID: String {
        return snapshot.documentID
    }

    var data: [String: Any] {
        return snapshot.data() ?? [:]
    }
}
