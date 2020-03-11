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

    init?(modelData: FirestoreModelData) {
        try? self.init(
            uid: modelData.documentID,
            userName: modelData.value(forKey: "userName"),
            email: modelData.value(forKey: "email")
        )
    }
}
