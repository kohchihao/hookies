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



}
