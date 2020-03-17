//
//  PlayerGameState.swift
//  Hookies
//
//  Created by Jun Wei Koh on 17/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

struct PlayerGameState {
    private(set) var playerId: String
    private(set) var position: Vector
    private(set) var velocity: Vector
    private(set) var powerupState: String
    private(set) var attachedPosition: Vector?
}

extension PlayerGameState: Hashable {
    public static func == (lhs: PlayerGameState, rhs: PlayerGameState) -> Bool {
         return lhs.playerId == rhs.playerId
     }

     public func hash(into hasher: inout Hasher) {
         hasher.combine(playerId)
     }
}
