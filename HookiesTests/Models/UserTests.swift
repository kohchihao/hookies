//
//  UserTests.swift
//  HookiesTests
//
//  Created by Marcus Koh on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest

@testable import Hookies

class UserTests: XCTestCase {

    var user: User!
    var user2: User!

    override func tearDown() {
        user = nil
        user2 = nil
        super.tearDown()
    }

    func testInitializationWithValidValues() {
        user = User(uid: "123", username: "123", email: "example@gmail.com")
        XCTAssertEqual(user.uid, "123")
        XCTAssertEqual(user.username, "123")
        XCTAssertEqual(user.email, "example@gmail.com")
    }

    func testInitializationWithEmptyEmail() {
        user = User(uid: "123", username: "123", email: nil)
        XCTAssertEqual(user.uid, "123")
        XCTAssertEqual(user.username, "123")
        XCTAssertEqual(user.email, "")
    }

    func testInitializationWithEmptyString() {
        user = User(uid: "", username: "", email: "")
        XCTAssertEqual(user.uid, "")
        XCTAssertEqual(user.username, "")
        XCTAssertEqual(user.email, "")
    }

    func testEqualityEqual() {
        user = User(uid: "123", username: "123", email: "example@gmail.com")
        user2 = User(uid: "123", username: "1235", email: "example1@gmail.com")
        XCTAssertEqual(user, user2)
    }

    func testEqualityNotEqual() {
        user = User(uid: "1233", username: "123", email: "example@gmail.com")
        user2 = User(uid: "123", username: "123", email: "example@gmail.com")
        XCTAssertNotEqual(user, user2)
    }

    func testHash() {
        user = User(uid: "123", username: "123", email: "example@gmail.com")
        var set = Set<User>()
        set.insert(user)
        XCTAssertEqual(set.count, 1)

        set.remove(user)
        XCTAssertEqual(set.count, 0)
    }
}
