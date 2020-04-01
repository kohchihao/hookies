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

    func testInitializationWithValidValues() throws {
        user = try User(uid: "123", username: "1234")
        XCTAssertEqual(user.uid, "123")
        XCTAssertEqual(user.username, "1234")
    }

    func testEqualityEqual() throws {
        user = try User(uid: "123", username: "1234")
        user2 = try User(uid: "123", username: "1235")
        XCTAssertEqual(user, user2)
    }

    func testEqualityNotEqual() throws {
        user = try User(uid: "1233", username: "1234")
        user2 = try User(uid: "123", username: "1234")
        XCTAssertNotEqual(user, user2)
    }

    func testUsernameTooShort() throws {
        let shortUsername = String(repeating: "a", count: User.minNameLen - 1)
        XCTAssertThrowsError(try User(uid: "12345", username: shortUsername))
    }

    func testUsernameTooLong() throws {
        let longUsername = String(repeating: "a", count: User.maxNameLen + 1)
        XCTAssertThrowsError(try User(uid: "12345", username: longUsername))
    }

    func testHash() throws {
        user = try User(uid: "1234", username: "1234")
        var set = Set<User>()
        set.insert(user)
        XCTAssertEqual(set.count, 1)

        set.remove(user)
        XCTAssertEqual(set.count, 0)
    }
}
