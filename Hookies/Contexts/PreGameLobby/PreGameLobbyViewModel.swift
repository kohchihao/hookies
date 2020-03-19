//
//  PreGameLobbyViewModel.swift
//  
//
//  Created by Marcus Koh on 15/3/20.
//

import Foundation
import FirebaseAuth
import UIKit

protocol PreGameLobbyViewModelRepresentable {
    var selectedMap: MapType? { get set }
    var delegate: RoomStateViewModelDelegate? { get set }
    var lobby: Lobby { get set }
}

class PreGameLobbyViewModel: PreGameLobbyViewModelRepresentable {
    var selectedMap: MapType?
    weak var delegate: RoomStateViewModelDelegate?
    var lobby: Lobby

    init() {
        guard let hostId = Auth.auth().currentUser?.uid else {
            fatalError("Host is not logged in")
        }
        self.lobby = Lobby(hostId: hostId)
    }
}

protocol RoomStateViewModelDelegate: class {
    func updateSelectedMap(mapType: MapType)
}
