//
//  Gameplay.swift
//  Hookies
//
//  Created by Jun Wei Koh on 16/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

struct Gameplay {
    private(set) var gameId: String
    private(set) var gameState: GameState
    private(set) var playersId: [String] = []

    init(gameId: String) {
        self.gameId = gameId
        self.gameState = .waiting
    }

    init(gameId: String, gameState: GameState, playersId: [String]) {
        self.gameId = gameId
        self.gameState = gameState
        self.playersId = playersId
    }
}
