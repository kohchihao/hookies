//
//  Request+FirestoreModel.swift
//  Hookies
//
//  Created by Tan LongBin on 1/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

extension Request: FirestoreModel {
    var documentID: String {
        return requestId
    }

    var encoding: [String: Any] {
        return defaultEncoding()
    }

    init?(modelData: FirestoreDataModel) {
        try? self.init(
            requestId: modelData.documentID,
            fromUserId: modelData.value(forKey: "fromUserId"),
            toUserId: modelData.value(forKey: "toUserId")
        )
    }
}
