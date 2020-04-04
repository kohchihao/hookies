//
//  API.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Firebase
import SocketIO

class API {
    static let shared = API()

    private let db: Firestore
    private let socketManager = SocketManager(socketURL: Config.socketURL)
    let user: UserStore
    let gameplay: GameplayStore
    let lobby: LobbyStore
    let social: SocialStore
    let request: RequestStore

    private init() {
        db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        user = UserStore(userCollection: db.collection("users"))
        gameplay = GameplayStore(gameplayCollection: db.collection("gameplays"),
                                 socketRef: socketManager.socket(forNamespace: "/games"))
        lobby = LobbyStore(lobbyCollection: db.collection("lobbies"))
        social = SocialStore(socialCollection: db.collection("socials"))
        request = RequestStore(requestCollection: db.collection("requests"))
    }
}
