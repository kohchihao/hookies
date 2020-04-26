//
//  InviteTests.swift
//  HookiesTests
//
//  Created by Tan LongBin on 26/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest

@testable import Hookies

class InviteTests: XCTestCase {

    var invite: Invite!
    let fromUserId = "testSender"
    let toUserId = "testRecipient"
    let lobbyID = "testLobby"
    let inviteID = "testInvite"

    override func tearDown() {
        invite = nil
        super.tearDown()
    }

    func testInitializationWithoutInviteId() {
        invite = Invite(fromUserId: fromUserId, toUserId: toUserId, lobbyId: lobbyID)
        XCTAssertEqual(invite.fromUserId, fromUserId)
        XCTAssertEqual(invite.toUserId, toUserId)
        XCTAssertEqual(invite.lobbyId, lobbyID)
        XCTAssertEqual(invite.inviteId.count, Constants.inviteIdLength)
    }

    func testInitializationWithInviteId() {
        invite = Invite(inviteId: inviteID, fromUserId: fromUserId, toUserId: toUserId, lobbyId: lobbyID)
        XCTAssertEqual(invite.fromUserId, fromUserId)
        XCTAssertEqual(invite.toUserId, toUserId)
        XCTAssertEqual(invite.lobbyId, lobbyID)
        XCTAssertEqual(invite.inviteId, inviteID)
    }
}
