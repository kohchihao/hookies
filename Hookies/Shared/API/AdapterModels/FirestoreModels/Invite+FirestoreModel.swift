//
//  Invite+FirestoreModel.swift
//  Hookies
//
//  Created by Tan LongBin on 4/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

extension Invite: FirestoreModel {
    var documentID: String {
        return inviteId
    }

    var encoding: [String : Any] {
        return defaultEncoding()
    }

    init?(modelData: FirestoreDataModel) {
        try? self.init(
            inviteId: modelData.documentID,
            fromUserId: modelData.value(forKey: "fromUserId"),
            toUserId: modelData.value(forKey: "toUserId"),
            lobbyId: modelData.value(forKey: "lobbyId")
        )
    }
}
