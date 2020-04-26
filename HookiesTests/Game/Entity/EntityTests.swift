//
//  EntityTests.swift
//  HookiesTests
//
//  Created by JinYing on 26/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest
@testable import Hookies

class EntityTests: XCTestCase {
    private class MockEntity: Entity {
        var components: [Component] = []

        init(components: [Component]) {
            self.components = components
        }

        convenience init() {
            self.init(components: [])

            let sprite = SpriteComponent(parent: self)
            let anotherSprite = SpriteComponent(parent: self)
            let translate = NonPhysicsTranslateComponent(parent: self)
            let rotate = RotateComponent(parent: self)

            addComponent(sprite)
            addComponent(anotherSprite)
            addComponent(translate)
            addComponent(rotate)
        }
    }

    private var sut = MockEntity()

    func testGet_componentExist_returnComponent() {
        let translate = sut.get(NonPhysicsTranslateComponent.self)

        XCTAssertNotNil(translate)
    }

    func testGet_componentDoesNotExist_returnNil() {
        let hook = sut.get(HookComponent.self)

        XCTAssertNil(hook)
    }

    func testGetMultiple_multipleComponents_returnAllComponents() {
        let sprites = sut.getMultiple(SpriteComponent.self)

        XCTAssertEqual(2, sprites.count)
    }

    func testGetMultiple_componentDoesNotExist_returnEmptyList() {
        let hooks = sut.getMultiple(HookComponent.self)

        XCTAssertEqual(0, hooks.count)
    }

    func testAddComponent_shouldAddComponent() {
        sut.addComponent(HookComponent(parent: sut))

        let hook = sut.get(HookComponent.self)
        XCTAssertEqual(5, sut.components.count)
        XCTAssertNotNil(hook)
    }

    func testRemoveFirstComponent_componentExist_shouldRemove() {
        guard let entityTranslate = sut.get(NonPhysicsTranslateComponent.self) else {
            XCTFail("No such component")
            return
        }

        sut.removeFirstComponent(of: entityTranslate)

        let translate = sut.get(NonPhysicsTranslateComponent.self)
        XCTAssertEqual(3, sut.components.count)
        XCTAssertNil(translate)
    }

    func testRemoveComponents_multipleComponents_shouldRemoveAll() {
        sut.removeComponents(SpriteComponent.self)

        let sprites = sut.getMultiple(SpriteComponent.self)
        XCTAssertEqual(2, sut.components.count)
        XCTAssertEqual(0, sprites.count)
    }
}
