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

/// A singleton that provides the API for the client side code to communicate with the backend.
class API {
    static let shared = API()

    private let db: Firestore
    /// Socket Manager Attributes:
    ///     - When disconnects, will attempt to reconnect
    ///     - Will never give up reconnecting
    private let socketManager = SocketManager(
        socketURL: Config.socketURL,
        config: [.reconnects(true), .reconnectAttempts(-1)])
    let user: UserStore
    let gameplay: GameplayStore
    let lobby: LobbyStore
    let social: SocialStore
    let request: RequestStore
    let invite: InviteStore

    private init() {
        db = Firestore.firestore()

        user = UserStore(userCollection: db.collection("users"))
        gameplay = GameplayStore(socketRef: socketManager.socket(forNamespace: "/games"))
        lobby = LobbyStore(lobbyCollection: db.collection("lobbies"),
                           socketRef: socketManager.socket(forNamespace: "/lobbies"))
        social = SocialStore(socialCollection: db.collection("socials"))
        request = RequestStore(requestCollection: db.collection("requests"))
        invite = InviteStore(inviteCollection: db.collection("invites"))
    }
}
