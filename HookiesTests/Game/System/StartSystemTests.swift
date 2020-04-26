//
//  StartSystemTests.swift
//  HookiesTests
//
//  Created by Marcus Koh on 26/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest
@testable import Hookies
class StartSystemTests: XCTestCase {

    var startSystem: StartSystem!

    var playerSprite: SpriteComponent!
    var playerEntity: PlayerEntity!
    var spriteSystem: SpriteSystem!

    override func setUp() {
        super.setUp()
        startSystem = StartSystem()
        spriteSystem = SpriteSystem()
        playerEntity = PlayerEntity()
        playerSprite = SpriteComponent(parent: playerEntity)
    }

    override func tearDown() {
        startSystem = nil
        playerSprite = nil
        playerEntity = nil
        spriteSystem = nil
        super.tearDown()
    }

    func testAddSinglePlayer() {
        expectation(
            forNotification: .addPlayersMapping,
            object: startSystem,
            handler: nil)

        _ = spriteSystem.set(sprite: playerSprite, of: .player1, with: "Pink_Monster", at: CGPoint(x: 10, y: 20))
        guard let player = Player(
            playerId: "abc",
            playerType: .human,
            costumeType: .Pink_Man,
            isCurrentPlayer: true,
            isHost: true
            ) else {
                XCTFail("Failed to get player")
                return
        }
        XCTAssertNoThrow(startSystem.add(player: player, with: playerSprite))
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testAddMultiplePlayer() {
        expectation(
            forNotification: .addPlayersMapping,
            object: startSystem,
            handler: nil)

        _ = spriteSystem.set(sprite: playerSprite, of: .player1, with: "Pink_Monster", at: CGPoint(x: 10, y: 20))
        guard let player = Player(
            playerId: "abc",
            playerType: .human,
            costumeType: .Pink_Man,
            isCurrentPlayer: true,
            isHost: true
            ) else {
                XCTFail("Failed to get player")
                return
        }
        XCTAssertNoThrow(startSystem.add(players: [player], with: [playerSprite]))
        waitForExpectations(timeout: 1, handler: nil)
    }
}
