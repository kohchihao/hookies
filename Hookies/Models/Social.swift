//
//  Social.swift
//  Hookies
//
//  Created by Tan LongBin on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

/// Social holds all the social data structures related to the player

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

    /// Add the incoming request to the social
    mutating func addIncomingRequest(requestId: String) {
        if !self.incomingRequests.contains(requestId) {
            self.incomingRequests.append(requestId)
        }
    }

    /// Add the outgoing request to the social
    mutating func addOutgoingRequest(requestId: String) {
        if !self.outgoingRequests.contains(requestId) {
            self.outgoingRequests.append(requestId)
        }
    }

    /// Remove the request from social
    mutating func removeRequest(requestId: String) {
        self.incomingRequests = self.incomingRequests.filter({ $0 != requestId })
        self.outgoingRequests = self.outgoingRequests.filter({ $0 != requestId })
    }

    /// Add friend to social
    mutating func addFriend(userId: String) {
        if !self.friends.contains(userId) {
            self.friends.append(userId)
        }
    }

    /// Remove friend from social
    mutating func removeFriend(userId: String) {
        self.friends = self.friends.filter({ $0 != userId })
    }

    /// Add the incoming invite to the social
    mutating func addIncomingInvite(inviteId: String) {
        if !self.incomingInvites.contains(inviteId) {
            self.incomingInvites.append(inviteId)
        }
    }

    /// Add the outgoing invite to the social
    mutating func addOutgoingInvite(inviteId: String) {
        if !self.outgoingInvites.contains(inviteId) {
            self.outgoingInvites.append(inviteId)
        }
    }

    /// Remove the invite from social
    mutating func removeInvite(inviteId: String) {
        self.incomingInvites = self.incomingInvites.filter({ $0 != inviteId })
        self.outgoingInvites = self.outgoingInvites.filter({ $0 != inviteId })
    }
}
