//
//  SocketRoom.swift
//  Hookies
//
//  Created by Jun Wei Koh on 13/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SocketIO

protocol SocketRoom {
    var socket: SocketIOClient { get }
}

extension SocketRoom {
    /// Will remove all listeners that has been added the current room session.
    func close() {
        socket.removeAllHandlers()
        socket.disconnect()
    }

    /// Connect the current user to the defined room id.
    /// In the completion handler, it will return you an array of String representing uids of other players
    /// that are currently in the room.
    func connect(roomId: String, completion: @escaping ([String]) -> Void) {
        socket.connect()
        socket.once(clientEvent: .connect) { _, _ in
            self.joinRoom(roomId: roomId, completion: completion)
        }
    }

    /// Whenever there is a change in connection status of other players, the listener will be triggered.
    func subscribeToPlayersConnection(listener: @escaping (UserConnectionState) -> Void) {
        socket.on("joinedRoom") { data, _ in
            guard let userId = self.decodeStringData(data: data) else {
                return
            }
            listener(UserConnectionState(uid: userId, state: .connected))
        }
        socket.on("leftRoom") { data, _ in
            guard let userId = self.decodeStringData(data: data) else {
                return
            }
            listener(UserConnectionState(uid: userId, state: .disconnected))
        }
    }

    /// Whenever there is a change in connection status of the current user, the listener will be triggered.
    func subscribeToRoomConnection(roomId: String,
                                   listener: @escaping (ConnectionState) -> Void
    ) {
        socket.on(clientEvent: .connect) { _, _ in
            listener(.connected)
            self.joinRoom(roomId: roomId, completion: { _ in })
        }
        socket.on(clientEvent: .disconnect) { _, _ in
            listener(.disconnected)
        }
        socket.on(clientEvent: .reconnectAttempt) { _, _ in
            listener(.disconnected)
        }
    }

    private func joinRoom(roomId: String,
                          completion: @escaping ([String]) -> Void
    ) {
        guard let currentUser = API.shared.user.currentUser else {
            return
        }

        self.socket.emitWithAck("joinRoom", [
            "user": currentUser.uid,
            "roomId": roomId
        ]).timingOut(after: 1.0) { ack in
            let otherOnlineUsers = self.decodePlayersInRoomData(data: ack)
                .filter({ $0 != currentUser.uid })
            completion(otherOnlineUsers)
        }
    }

    private func decodePlayersInRoomData(data: [Any]) -> [String] {
        return data.compactMap({ $0 as? [String] })
            .flatMap({ $0 })
    }

    private func decodeStringData(data: [Any]) -> String? {
        if data.isEmpty {
            return nil
        }
        return data.compactMap({ $0 as? String })[0]
    }
}
