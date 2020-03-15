//
//  PreGameLobbyViewModel.swift
//  
//
//  Created by Marcus Koh on 15/3/20.
//

import Foundation

protocol PreGameLobbyViewModelRepresentable {
    var selectedMap: MapType? { get set }
    var delegate: RoomStateViewModelDelegate? { get set }
}

class PreGameLobbyViewModel: PreGameLobbyViewModelRepresentable {
    var selectedMap: MapType?
    weak var delegate: RoomStateViewModelDelegate?
}

protocol RoomStateViewModelDelegate: class {
    func updateSelectedMap(mapType: MapType)
}
