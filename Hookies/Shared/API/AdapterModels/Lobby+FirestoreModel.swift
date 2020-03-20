//
//  Lobby+FirestoreModel.swift
//  Hookies
//
//  Created by Jun Wei Koh on 20/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

extension Lobby: FirestoreModel {
    var documentID: String {
        return lobbyId
    }

    var serialized: [String: Any?] {
        return defaultSerializer()
    }

    init?(modelData: FirestoreDataModel) {
        try? self.init(
            lobbyId: modelData.documentID,
            hostId: modelData.value(forKey: "hostId"),
            mapId: modelData.optionalValue(forKey: "mapId"),
            playersId: modelData.value(forKey: "playersId"),
            costumes: modelData.value(forKey: "costumes")
        )
    }
}
