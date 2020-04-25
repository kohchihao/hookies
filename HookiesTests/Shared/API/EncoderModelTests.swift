////
////  EncoderModelTests.swift
////  HookiesTests
////
////  Created by Jun Wei Koh on 2/4/20.
////  Copyright © 2020 Hookies. All rights reserved.
////
//
//import XCTest
//@testable import Hookies
//
//class EncoderModelTests: XCTestCase {
//    var playerDataModel: PlayerData!
//    var hookDataModel: HookActionData!
//
//    override func setUp() {
//        super.setUp()
//        playerDataModel = PlayerData(playerId: "1234", position: Vector(x: 300, y: 300),
//                                     velocity: Vector(x: 500, y: 200))
//        hookDataModel = HookActionData(playerId: "1234",
//                                       position: Vector(x: 300, y: 300),
//                                       velocity: Vector(x: 500, y: 200),
//                                       type: .activate)
//    }
//
//    func testDecode() {
//        let expected: [String: Any] = [
//            "playerId": "1234",
//            "positionX": 300, "positionY": 300,
//            "velocityX": 500, "velocityY": 200
//        ]
//        XCTAssertTrue(NSDictionary(dictionary: playerDataModel.encoding)
//            .isEqual(to: expected))
//    }
//
//    func testDecodeNestedDataAndEnum() {
//        let expected: [String: Any] = [
//            "playerId": "1234",
//            "positionX": 300, "positionY": 300,
//            "velocityX": 500, "velocityY": 200,
//            "actionType": "activate"
//        ]
//        XCTAssertTrue(NSDictionary(dictionary: hookDataModel.encoding)
//            .isEqual(to: expected))
//    }
//
//    func testEncodeNilData() {
//        playerDataModel = PlayerData(playerId: "1234",
//                                     position: Vector(x: 300, y: 300),
//                                     velocity: nil)
//        let expected: [String: Any] = [
//            "playerId": "1234",
//            "positionX": 300, "positionY": 300
//        ]
//        XCTAssertTrue(NSDictionary(dictionary: playerDataModel.encoding)
//            .isEqual(to: expected))
//    }
//}
