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
        do {
            guard let status = RequestStatus(rawValue: try
                modelData.value(forKey: "status")) else {
                    return nil
            }
            try self.init(
                requestId: modelData.documentID,
                fromUserId: modelData.value(forKey: "fromUserId"),
                toUserId: modelData.value(forKey: "toUserId"),
                status: status
            )
        } catch {
            return nil
        }
    }
}
