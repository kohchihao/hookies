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
        return defaultSerializer()
    }

    init?(modelData: FirestoreDataModel) {
        do {
            guard let gameState = try GameState(rawValue: modelData.value(forKey: "gameState"))
                else {
                    return nil
            }
            try self.init(
                gameId: modelData.documentID,
                gameState: gameState,
                playersId: modelData.value(forKey: "playersId")
            )
        } catch {
            return nil
        }
    }
}
