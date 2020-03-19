//
//  Gameplay+FirestoreModel.swift
//  Hookies
//
//  Created by Jun Wei Koh on 16/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

extension Gameplay: FirestoreModel {
    var documentID: String {
        return gameId
    }

    var serialized: [String: Any?] {
        return [
            "gameId": documentID,
            "playersId": playersId
        ]
    }

    init?(modelData: FirestoreDataModel) {
        try? self.init(
            gameId: modelData.documentID,
            playersId: modelData.value(forKey: "playersId")
        )
    }
}
