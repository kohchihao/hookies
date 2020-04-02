//
//  Request.swift
//  Hookies
//
//  Created by Tan LongBin on 1/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

struct Request {
    private(set) var requestId: String
    private(set) var fromUserId: String
    private(set) var toUserId: String
    private(set) var status: RequestStatus

    init(fromUserId: String, toUserId: String) {
        self.requestId = RandomIDGenerator.getRandomID(length: Constants.requestIdLength)
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.status = .pending
    }

    init(requestId: String, fromUserId: String, toUserId: String, status: RequestStatus) {
        self.requestId = requestId
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.status = status
    }
}
