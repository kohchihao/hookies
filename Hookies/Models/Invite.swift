//
//  Invite.swift
//  Hookies
//
//  Created by Tan LongBin on 4/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

struct Invite {
    private(set) var inviteId: String
    private(set) var lobbyId: String
    private(set) var fromUserId: String
    private(set) var toUserId: String

    init(fromUserId: String, toUserId: String, lobbyId: String) {
        self.inviteId = RandomIDGenerator.getRandomID(length: Constants.inviteIdLength)
        self.lobbyId = lobbyId
        self.fromUserId = fromUserId
        self.toUserId = toUserId
    }

    init(inviteId: String, fromUserId: String, toUserId: String, lobbyId: String) {
        self.inviteId = inviteId
        self.lobbyId = lobbyId
        self.fromUserId = fromUserId
        self.toUserId = toUserId
    }
}
