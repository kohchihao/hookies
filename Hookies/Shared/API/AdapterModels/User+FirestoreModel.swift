//
//  User.swift
//  Hookies
//
//  Created by Jun Wei Koh on 11/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

extension User: FirestoreModel {
    var documentID: String {
        return uid
    }

    var serialized: [String: Any?] {
        return defaultSerializer()
    }

    init?(modelData: FirestoreDataModel) {
        try? self.init(
            uid: modelData.documentID,
            username: modelData.value(forKey: "username"),
            email: modelData.value(forKey: "email")
        )
    }
}
