//
//  FirestoreModel.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

private struct Property {
    let label: String
    let value: Any
}

import FirebaseFirestore

protocol FirestoreModel {
    init?(modelData: FirestoreModelData)

    /// ID of the document in Firestore.
    var documentID: String { get }

    /// Will serialize a strong type casted model into a dictionary.
    /// Where its properties are String and values are of type Any.
    var serialized: [String: Any?] { get }
}

extension FirestoreModel {

    var serialized: [String: Any?] {
        var data = [String: Any?]()
        Mirror(reflecting: self).children.forEach { child in
            guard let property = child.label.flatMap({ Property(label: $0, value: child.value) }) else {
                return
            }

            data[property.label] = property.value
        }

        return data
    }
}
