//
//  Social.swift
//  Hookies
//
//  Created by Tan LongBin on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

struct Social {
    private(set) var userId: String
    private(set) var friends: [String] = []
    private(set) var incomingRequests: [String] = []
    private(set) var outgoingRequests: [String] = []
    private(set) var incomingInvites: [String] = []
    private(set) var outgoingInvites: [String] = []

    init(userId: String) {
        self.userId = userId
    }

    init(
        userId: String,
        friends: [String],
        inRequests: [String],
        outRequests: [String],
        inInvites: [String],
        outInvites: [String]
    ) {
        self.userId = userId
        self.friends = friends
        self.incomingRequests = inRequests
        self.outgoingRequests = outRequests
        self.incomingInvites = inInvites
        self.outgoingInvites = outInvites
    }

    mutating func addIncomingRequest(requestId: String) {
        if !self.incomingRequests.contains(requestId) {
            self.incomingRequests.append(requestId)
        }
    }

    mutating func addOutgoingRequest(requestId: String) {
        if !self.outgoingRequests.contains(requestId) {
            self.outgoingRequests.append(requestId)
        }
    }

    mutating func removeRequest(requestId: String) {
        self.incomingRequests = self.incomingRequests.filter({ $0 != requestId })
        self.outgoingRequests = self.outgoingRequests.filter({ $0 != requestId })
    }

    mutating func addFriend(userId: String) {
        if !self.friends.contains(userId) {
            self.friends.append(userId)
        }
    }

    mutating func removeFriend(userId: String) {
        self.friends = self.friends.filter({ $0 != userId })
    }

    mutating func addIncomingInvite(inviteId: String) {
        self.incomingInvites.append(inviteId)
    }

    mutating func addOutgoingInvite(inviteId: String) {
        self.outgoingInvites.append(inviteId)
    }

    mutating func removeInvite(inviteId: String) {
        self.incomingInvites = self.incomingInvites.filter({ $0 != inviteId })
        self.outgoingInvites = self.outgoingInvites.filter({ $0 != inviteId })
    }
}
