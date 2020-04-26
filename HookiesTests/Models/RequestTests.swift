//
//  RequestTests.swift
//  HookiesTests
//
//  Created by Tan LongBin on 26/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest

@testable import Hookies

class RequestTests: XCTestCase {

    var request: Request!
    let fromUserId = "testSender"
    let toUserId = "testRecipient"
    let requestID = "testRequest"

    override func tearDown() {
        request = nil
        super.tearDown()
    }

    func testInitializationWithoutRequestId() {
        request = Request(fromUserId: fromUserId, toUserId: toUserId)
        XCTAssertEqual(request.fromUserId, fromUserId)
        XCTAssertEqual(request.toUserId, toUserId)
        XCTAssertEqual(request.requestId.count, Constants.requestIdLength)
    }

    func testInitializationWithRequestId() {
        request = Request(requestId: requestID, fromUserId: fromUserId, toUserId: toUserId)
        XCTAssertEqual(request.fromUserId, fromUserId)
        XCTAssertEqual(request.toUserId, toUserId)
        XCTAssertEqual(request.requestId, requestID)
    }
}
