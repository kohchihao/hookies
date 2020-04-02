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
    private(set) var requests: [String] = []
    private(set) var invites: [String] = []

    init(userId: String) {
        self.userId = userId
    }

    init(userId: String, friends: [String], requests: [String], invites: [String]) {
        self.userId = userId
        self.friends = friends
        self.requests = requests
        self.invites = invites
    }

    mutating func addRequest(requestId: String) {
        self.requests.append(requestId)
    }
}
