//
//  Social+FirestoreModel.swift
//  Hookies
//
//  Created by Tan LongBin on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

extension Social: FirestoreModel {
    var documentID: String {
        return userId
    }

    var encoding: [String: Any] {
        return defaultEncoding()
    }

    init?(modelData: FirestoreDataModel) {
        try? self.init(
            userId: modelData.documentID,
            friends: modelData.value(forKey: "friends"),
            inRequests: modelData.value(forKey: "incomingRequests"),
            outRequests: modelData.value(forKey: "outgoingRequests"),
            inInvites: modelData.value(forKey: "incomingInvites"),
            outInvites: modelData.value(forKey: "outgoingInvites")
        )
    }
}
