//
//  FirestoreModelData.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct FirestoreModelData {

    let snapshot: DocumentSnapshot

    var documentID: String {
        return snapshot.documentID
    }

    var data: [String: Any] {
        return snapshot.data() ?? [:]
    }

    func value<T>(forKey key: String) throws -> T {
        guard let value = data[key] as? T else {
            throw ModelDataError.typeCastFailed
        }
        return value
    }

    func optionalValue<T>(forKey key: String) -> T? {
        return data[key] as? T
    }

    enum ModelDataError: Error {
        case typeCastFailed
    }
}
