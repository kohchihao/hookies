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
}

class GamePlayViewModel: GamePlayViewModelRepresentable {
    var selectedMap: MapType

    init(withSelectedMap selectedMap: MapType) {
        self.selectedMap = selectedMap
    }

}
