//
//  API.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Firebase

class API {
    static let shared = API()

    private let db: Firestore
    let user: UserStore
    let gameplay: GameplayStore
    let lobby: LobbyStore

    private init() {
        db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        user = UserStore(userCollection: db.collection("users"))
        gameplay = GameplayStore(gameplayCollection: db.collection("gameplays"))
        lobby = LobbyStore(lobbyCollection: db.collection("lobbies"))
    }
}
