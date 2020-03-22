//
//  GameViewModel.swift
//  Hookies
//
//  Created by Marcus Koh on 15/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol GamePlayViewModelRepresentable {
    var selectedMap: MapType { get set }
    var gameplayId: String { get }
}

class GamePlayViewModel: GamePlayViewModelRepresentable {
    var selectedMap: MapType
    let gameplayId: String

    init(withSelectedMap selectedMap: MapType, and gameplayId: String) {
        self.selectedMap = selectedMap
        self.gameplayId = gameplayId
    }

}
