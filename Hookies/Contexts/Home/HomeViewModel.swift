//
//  HomeViewModel.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol HomeViewModelRepresentable {
}

class HomeViewModel: HomeViewModelRepresentable {
    init() {
        API.shared.gameplay.subscribeToPlayerStates(gameId: "JR2yO21QQAVabXNcAV3A") { states, error in
            print(states)
        }
//        let players = ["EwIxUZMUE5STS2AJ1cDK9vZHcUc2", "3DlgEMdZCGSwaoHNGsVI9TvFMDE2"]
//        var gameplay = Gameplay(gameId: "JR2yO21QQAVabXNcAV3A", playersId: players)
//        let powerup = HookPowerup(isActivated: true, ownerId: "EwIxUZMUE5STS2AJ1cDK9vZHcUc2")
//        let playerGameState = [
//            PlayerGameState(playerId: "EwIxUZMUE5STS2AJ1cDK9vZHcUc2",
//                                position: Vector(x: 144, y: 23),
//                                velocity: Vector(x: 300, y: 200),
//                                powerup: powerup)
//        ]
//        gameplay.updatePlayerStates(with: playerGameState)
//        API.shared.gameplay.save(gameplay: gameplay, completion: { gameplay, error in
//            print(gameplay)
//        })
//        let gameId = "JR2yO21QQAVabXNcAV3A"
//        API.shared.gameplay.get(gameId: gameId, completion: { gameplay, error in
//            print(gameplay)
//        })
    }
}
