//
//  SocialTests.swift
//  HookiesTests
//
//  Created by Tan LongBin on 26/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest

@testable import Hookies

class SocialTests: XCTestCase {

    var social: Social!
    let userId = "testSender"
    let friendId = "testFriend"
    let inviteId = "testInvite"
    let requestId = "testRequest"

    override func tearDown() {
        social = nil
        super.tearDown()
    }

    func testInitializationWithUserIdOnly() {
        social = Social(userId: userId)
        XCTAssertEqual(social.userId, userId)
        XCTAssertEqual(social.friends, [])
        XCTAssertEqual(social.incomingRequests, [])
        XCTAssertEqual(social.outgoingRequests, [])
        XCTAssertEqual(social.incomingInvites, [])
        XCTAssertEqual(social.outgoingInvites, [])
    }

    func testInitializationWithAllParams() {
        social = Social(userId: userId, friends: ["testFriend"], inRequests: ["testInRequest"],
                        outRequests: ["testOutRequest"], inInvites: ["testInInvite"], outInvites: ["testOutInvite"])
        XCTAssertEqual(social.userId, userId)
        XCTAssertEqual(social.friends, ["testFriend"])
        XCTAssertEqual(social.incomingRequests, ["testInRequest"])
        XCTAssertEqual(social.outgoingRequests, ["testOutRequest"])
        XCTAssertEqual(social.incomingInvites, ["testInInvite"])
        XCTAssertEqual(social.outgoingInvites, ["testOutInvite"])
    }

    func testInitializationWithEmptyFriends() {
        social = Social(userId: userId, friends: [], inRequests: ["testInRequest"],
                        outRequests: ["testOutRequest"], inInvites: ["testInInvite"], outInvites: ["testOutInvite"])
        XCTAssertEqual(social.userId, userId)
        XCTAssertEqual(social.friends, [])
        XCTAssertEqual(social.incomingRequests, ["testInRequest"])
        XCTAssertEqual(social.outgoingRequests, ["testOutRequest"])
        XCTAssertEqual(social.incomingInvites, ["testInInvite"])
        XCTAssertEqual(social.outgoingInvites, ["testOutInvite"])
    }

    func testInitializationWithEmptyIncomingRequests() {
        social = Social(userId: userId, friends: ["testFriend"], inRequests: [],
                        outRequests: ["testOutRequest"], inInvites: ["testInInvite"], outInvites: ["testOutInvite"])
        XCTAssertEqual(social.userId, userId)
        XCTAssertEqual(social.friends, ["testFriend"])
        XCTAssertEqual(social.incomingRequests, [])
        XCTAssertEqual(social.outgoingRequests, ["testOutRequest"])
        XCTAssertEqual(social.incomingInvites, ["testInInvite"])
        XCTAssertEqual(social.outgoingInvites, ["testOutInvite"])
    }

    func testInitializationWithEmptyOutgoingRequests() {
        social = Social(userId: userId, friends: ["testFriend"], inRequests: ["testInRequest"],
                        outRequests: [], inInvites: ["testInInvite"], outInvites: ["testOutInvite"])
        XCTAssertEqual(social.userId, userId)
        XCTAssertEqual(social.friends, ["testFriend"])
        XCTAssertEqual(social.incomingRequests, ["testInRequest"])
        XCTAssertEqual(social.outgoingRequests, [])
        XCTAssertEqual(social.incomingInvites, ["testInInvite"])
        XCTAssertEqual(social.outgoingInvites, ["testOutInvite"])
    }

    func testInitializationWithEmptyIncomingInvites() {
        social = Social(userId: userId, friends: ["testFriend"], inRequests: ["testInRequest"],
                        outRequests: ["testOutRequest"], inInvites: [], outInvites: ["testOutInvite"])
        XCTAssertEqual(social.userId, userId)
        XCTAssertEqual(social.friends, ["testFriend"])
        XCTAssertEqual(social.incomingRequests, ["testInRequest"])
        XCTAssertEqual(social.outgoingRequests, ["testOutRequest"])
        XCTAssertEqual(social.incomingInvites, [])
        XCTAssertEqual(social.outgoingInvites, ["testOutInvite"])
    }

    func testInitializationWithEmptyOutgoingInvites() {
        social = Social(userId: userId, friends: ["testFriend"], inRequests: ["testInRequest"],
                        outRequests: ["testOutRequest"], inInvites: ["testInInvite"], outInvites: [])
        XCTAssertEqual(social.userId, userId)
        XCTAssertEqual(social.friends, ["testFriend"])
        XCTAssertEqual(social.incomingRequests, ["testInRequest"])
        XCTAssertEqual(social.outgoingRequests, ["testOutRequest"])
        XCTAssertEqual(social.incomingInvites, ["testInInvite"])
        XCTAssertEqual(social.outgoingInvites, [])
    }

    func testAddIncomingRequest() {
        social = Social(userId: userId)
        social.addIncomingRequest(requestId: requestId)
        XCTAssertEqual(social.incomingRequests, [requestId])
    }

    func testAddRepeatedIncomingRequest() {
        social = Social(userId: userId)
        social.addIncomingRequest(requestId: requestId)
        XCTAssertEqual(social.incomingRequests, [requestId])
        social.addIncomingRequest(requestId: requestId)
        XCTAssertEqual(social.incomingRequests, [requestId])
    }

    func testAddOutgoingRequest() {
        social = Social(userId: userId)
        social.addOutgoingRequest(requestId: requestId)
        XCTAssertEqual(social.outgoingRequests, [requestId])
    }

    func testAddRepeatedOutgoingRequest() {
        social = Social(userId: userId)
        social.addOutgoingRequest(requestId: requestId)
        XCTAssertEqual(social.outgoingRequests, [requestId])
        social.addOutgoingRequest(requestId: requestId)
        XCTAssertEqual(social.outgoingRequests, [requestId])
    }

    func testRemoveRequest() {
        social = Social(userId: userId)
        social.addIncomingRequest(requestId: requestId)
        XCTAssertEqual(social.incomingRequests, [requestId])
        social.removeRequest(requestId: requestId)
        XCTAssertEqual(social.incomingRequests, [])
        social.addOutgoingRequest(requestId: requestId)
        XCTAssertEqual(social.outgoingRequests, [requestId])
        social.removeRequest(requestId: requestId)
        XCTAssertEqual(social.outgoingRequests, [])

        social.addIncomingRequest(requestId: requestId)
        XCTAssertEqual(social.incomingRequests, [requestId])
        social.addOutgoingRequest(requestId: requestId)
        XCTAssertEqual(social.outgoingRequests, [requestId])
        social.removeRequest(requestId: requestId)
        XCTAssertEqual(social.incomingRequests, [])
        XCTAssertEqual(social.outgoingRequests, [])
    }

    func testAddFriend() {
        social = Social(userId: userId)
        social.addFriend(userId: friendId)
        XCTAssertEqual(social.friends, [friendId])
    }

    func testAddRepeatedFriend() {
        social = Social(userId: userId)
        social.addFriend(userId: friendId)
        XCTAssertEqual(social.friends, [friendId])
        social.addFriend(userId: friendId)
        XCTAssertEqual(social.friends, [friendId])
    }

    func testRemoveFriend() {
        social = Social(userId: userId)
        social.addFriend(userId: friendId)
        XCTAssertEqual(social.friends, [friendId])
        social.removeFriend(userId: friendId)
        XCTAssertEqual(social.friends, [])
    }

    func testAddIncomingInvite() {
        social = Social(userId: userId)
        social.addIncomingInvite(inviteId: inviteId)
        XCTAssertEqual(social.incomingInvites, [inviteId])
    }

    func testAddRepeatedIncomingInvite() {
        social = Social(userId: userId)
        social.addIncomingInvite(inviteId: inviteId)
        XCTAssertEqual(social.incomingInvites, [inviteId])
        social.addIncomingInvite(inviteId: inviteId)
        XCTAssertEqual(social.incomingInvites, [inviteId])
    }

    func testAddOutgoingInvite() {
        social = Social(userId: userId)
        social.addOutgoingInvite(inviteId: inviteId)
        XCTAssertEqual(social.outgoingInvites, [inviteId])
    }

    func testAddRepeatedOutgoingInvite() {
        social = Social(userId: userId)
        social.addOutgoingInvite(inviteId: inviteId)
        XCTAssertEqual(social.outgoingInvites, [inviteId])
        social.addOutgoingInvite(inviteId: inviteId)
        XCTAssertEqual(social.outgoingInvites, [inviteId])
    }

    func testRemoveInvite() {
        social = Social(userId: userId)
        social.addIncomingInvite(inviteId: inviteId)
        XCTAssertEqual(social.incomingInvites, [inviteId])
        social.removeInvite(inviteId: inviteId)
        XCTAssertEqual(social.incomingInvites, [])
        social.addOutgoingInvite(inviteId: inviteId)
        XCTAssertEqual(social.outgoingInvites, [inviteId])
        social.removeInvite(inviteId: inviteId)
        XCTAssertEqual(social.outgoingInvites, [])

        social.addIncomingInvite(inviteId: inviteId)
        XCTAssertEqual(social.incomingInvites, [inviteId])
        social.addOutgoingInvite(inviteId: inviteId)
        XCTAssertEqual(social.outgoingInvites, [inviteId])
        social.removeInvite(inviteId: inviteId)
        XCTAssertEqual(social.incomingInvites, [])
        XCTAssertEqual(social.outgoingInvites, [])
    }
}
