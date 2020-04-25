//
//  EncoderModelTests.swift
//  HookiesTests
//
//  Created by Jun Wei Koh on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest
@testable import Hookies

class EncoderModelTests: XCTestCase {
    var playerDataModel: PlayerData!
    var genericEvent: GenericPlayerEventData!

    override func setUp() {
        super.setUp()
    }

    func testDecode() {
        playerDataModel = PlayerData(playerId: "1234",
                                     position: Vector(x: 300, y: 300),
                                     velocity: Vector(x: 500, y: 200))
        let expected: [String: Any] = [
            "playerId": "1234",
            "positionX": 300, "positionY": 300,
            "velocityX": 500, "velocityY": 200
        ]
        XCTAssertTrue(NSDictionary(dictionary: playerDataModel.encoding)
            .isEqual(to: expected))
    }

    func testDecodeNestedDataAndEnum() {
        genericEvent = GenericPlayerEventData(playerId: "1234",
                                              position: Vector(x: 300, y: 300),
                                              velocity: Vector(x: 500, y: 200),
                                              type: .hook)
        let expected: [String: Any] = [
            "playerId": "1234",
            "positionX": 300, "positionY": 300,
            "velocityX": 500, "velocityY": 200,
            "type": "hook"
        ]
        XCTAssertTrue(NSDictionary(dictionary: genericEvent.encoding)
            .isEqual(to: expected))
    }

    func testEncodeNilData() {
        genericEvent = GenericPlayerEventData(playerId: "1234",
                                              position: Vector(x: 300, y: 300),
                                              velocity: nil,
                                              type: .hook)
        let expected: [String: Any] = [
            "playerId": "1234",
            "positionX": 300, "positionY": 300,
            "type": "hook"
        ]
        XCTAssertTrue(NSDictionary(dictionary: genericEvent.encoding)
            .isEqual(to: expected))
    }
}
