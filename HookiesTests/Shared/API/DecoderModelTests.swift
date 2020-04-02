//
//  DictionaryModelTests.swift
//  HookiesTests
//
//  Created by Jun Wei Koh on 1/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest
@testable import Hookies

class DecoderModelTests: XCTestCase {
    let data: [String: Any] = [
        "data1": 32,
        "data2": "test",
        "optionalData": "optional"
    ]
    var model: DictionaryModel!

    override func setUp() {
        super.setUp()
        self.model = DictionaryModel(data: data)
    }

    func testDecodeCompulsoryField() throws {
        let data1Val: Int = try model.value(forKey: "data1")
        XCTAssertEqual(data1Val, 32)
        XCTAssertThrowsError(try model.value(forKey: "non-exist") as Int)
    }

    func testDecodeOptionalFields() throws {
        let optionalDataVal: String? = model.optionalValue(forKey: "optionalData")
        let nonExistentData: String? = model.optionalValue(forKey: "notexist")
        XCTAssertEqual(optionalDataVal, "optional")
        XCTAssertNil(nonExistentData)
    }
}
