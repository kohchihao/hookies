//
//  VectorTests.swift
//  HookiesTests
//
//  Created by Marcus Koh on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest

import Firebase
@testable import Hookies

class VectorTests: XCTestCase {

    var vector: Vector!
    var vector2: Vector!

    override func tearDown() {
        vector = nil
        vector2 = nil
        super.tearDown()
    }

    func testInitializationWithInteger() {
        vector = Vector(x: 1, y: 1)
        XCTAssertNotNil(vector, "Vector should not be nil")
    }

    func testInitializationWithDouble() {
        vector = Vector(x: 1.2, y: 1.5)
        XCTAssertNotNil(vector, "Vector should not be nil")
    }

    func testMagnitudePositiveVector() {
        vector = Vector(x: 1.0, y: 1.0)
        XCTAssertEqual(vector.magnitude, 1.4142135623730951, "Magnitude should be 1.4142135623730951")
    }

    func testMagnitudeNegativeVector() {
        vector = Vector(x: -1.0, y: -1.0)
        XCTAssertEqual(vector.magnitude, 1.4142135623730951, "Magnitude should be 1.4142135623730951")
    }

    func testMagnitudeNegativeXVector() {
        vector = Vector(x: -1.0, y: 1.0)
        XCTAssertEqual(vector.magnitude, 1.4142135623730951, "Magnitude should be 1.4142135623730951")
    }

    func testMagnitudeNegativeYVector() {
        vector = Vector(x: 1.0, y: -1.0)
        XCTAssertEqual(vector.magnitude, 1.4142135623730951, "Magnitude should be 1.4142135623730951")
    }

    func testDistancePositiveToNegativeVector() {
        vector = Vector(x: 1.0, y: 1.0)
        vector2 = Vector(x: -1.0, y: -1.0)
        XCTAssertEqual(vector.distance(to: vector2), 2.8284271247461903, "Distance should be 2.8284271247461903")
    }

    func testDistancePositiveToPositiveVector() {
        vector = Vector(x: 1.0, y: 1.0)
        vector2 = Vector(x: 3.0, y: 3.0)
        XCTAssertEqual(vector.distance(to: vector2), 2.8284271247461903, "Distance should be 2.8284271247461903")
    }

    func testDistancePositiveToXNegativeVector() {
        vector = Vector(x: 1.0, y: 1.0)
        vector2 = Vector(x: -3.0, y: 3.0)
        XCTAssertEqual(vector.distance(to: vector2), 4.47213595499958, "Distance should be 4.47213595499958")
    }

    func testDistancePositiveToYNegativeVector() {
        vector = Vector(x: 1.0, y: 1.0)
        vector2 = Vector(x: 3.0, y: -3.0)
        XCTAssertEqual(vector.distance(to: vector2), 4.47213595499958, "Distance should be 4.47213595499958")
    }

    func testDotPositiveToPositiveVector() {
        vector = Vector(x: 1.0, y: 1.0)
        vector2 = Vector(x: 2.0, y: 2.0)
        XCTAssertEqual(vector.dot(with: vector2), 4, "Dot product should be 4")
    }

    func testDotPositiveToXNegativeVector() {
        vector = Vector(x: 1.0, y: 1.0)
        vector2 = Vector(x: -2.0, y: 2.0)
        XCTAssertEqual(vector.dot(with: vector2), 0, "Dot product should be 0")
    }

    func testDotPositiveToYNegativeVector() {
        vector = Vector(x: 1.0, y: 1.0)
        vector2 = Vector(x: 2.0, y: -2.0)
        XCTAssertEqual(vector.dot(with: vector2), 0, "Dot product should be 0")
    }

    func testdotPositiveToNegativeVector() {
        vector = Vector(x: 1.0, y: 1.0)
        vector2 = Vector(x: -2.0, y: -2.0)
        XCTAssertEqual(vector.dot(with: vector2), -4, "Dot product should be -4")
    }

    func testUnitPositiveVector() {
        vector = Vector(x: 1.0, y: 1.0)
        XCTAssertNotNil(vector.unit(), "Unit vector not nil")
        XCTAssertEqual(vector.unit().x, 0.7071067811865475)
        XCTAssertEqual(vector.unit().y, 0.7071067811865475)
    }

    func testUnitNegativeVector() {
        vector = Vector(x: -1.0, y: -1.0)
        XCTAssertNotNil(vector.unit(), "Unit vector not nil")
        XCTAssertEqual(vector.unit().x, -0.7071067811865475)
        XCTAssertEqual(vector.unit().y, -0.7071067811865475)
    }

    func testAddPositiveVector() {
        vector = Vector(x: 1.0, y: 1.0)
        vector2 = Vector(x: 1.0, y: 1.0)
        let finalVector = vector + vector2
        XCTAssertNotNil(finalVector, "Vector should not be nil")
        XCTAssertEqual(finalVector.x, 2)
        XCTAssertEqual(finalVector.y, 2)
    }

    func testAddNegativeVector() {
        vector = Vector(x: 1.0, y: 1.0)
        vector2 = Vector(x: -1.0, y: -1.0)
        let finalVector = vector + vector2
        XCTAssertNotNil(finalVector, "Vector should not be nil")
        XCTAssertEqual(finalVector.x, 0)
        XCTAssertEqual(finalVector.y, 0)
    }

    func testMinusPositiveVector() {
        vector = Vector(x: 1.0, y: 1.0)
        vector2 = Vector(x: 1.0, y: 1.0)
        let finalVector = vector - vector2
        XCTAssertNotNil(finalVector, "Vector should not be nil")
        XCTAssertEqual(finalVector.x, 0)
        XCTAssertEqual(finalVector.y, 0)
    }

    func testMinusNegativeVector() {
        vector = Vector(x: 1.0, y: 1.0)
        vector2 = Vector(x: -1.0, y: -1.0)
        let finalVector = vector - vector2
        XCTAssertNotNil(finalVector, "Vector should not be nil")
        XCTAssertEqual(finalVector.x, 2)
        XCTAssertEqual(finalVector.y, 2)
    }
}
