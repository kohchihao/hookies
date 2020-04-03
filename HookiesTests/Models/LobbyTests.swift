//
//  LobbyTests.swift
//  HookiesTests
//
//  Created by Marcus Koh on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest

@testable import Hookies

class LobbyTests: XCTestCase {

    var lobby: Lobby!

    override func tearDown() {
        lobby = nil
        super.tearDown()
    }

    func testInitializationWithHostIdOnly() {
        lobby = Lobby(hostId: "abcdefghi")
        XCTAssertEqual(lobby.hostId, "abcdefghi")
        XCTAssertEqual(lobby.playersId.count, 1)
        XCTAssertEqual(lobby.playersId, ["abcdefghi"])
        XCTAssertEqual(lobby.costumesId.count, 1)
        XCTAssertEqual(lobby.lobbyState, LobbyState.open)
        XCTAssertNil(lobby.selectedMapType)
        XCTAssertNotNil(lobby.lobbyId)
    }

    func testInitializationWithEmptyPlayersIdAndCostumesId() {
        lobby = Lobby(hostId: "abcdefghi", playersId: [], costumesId: [:])
        XCTAssertEqual(lobby.hostId, "abcdefghi")
        XCTAssertEqual(lobby.playersId.count, 1)
        XCTAssertEqual(lobby.playersId, ["abcdefghi"])
        XCTAssertEqual(lobby.costumesId.count, 1)
        XCTAssertEqual(lobby.lobbyState, LobbyState.open)
        XCTAssertNil(lobby.selectedMapType)
        XCTAssertNotNil(lobby.lobbyId)
    }

    func testInitializationWithPlayersIdAndCostumesId() {
        lobby = Lobby(hostId: "abcdefghi", playersId: ["1234", "2345"], costumesId: [:])
        XCTAssertEqual(lobby.hostId, "abcdefghi")
        XCTAssertEqual(lobby.playersId.count, 3)
        XCTAssertEqual(lobby.playersId, ["abcdefghi", "1234", "2345"])
        XCTAssertEqual(lobby.costumesId.count, 3)
        XCTAssertEqual(lobby.lobbyState, LobbyState.open)
        XCTAssertNil(lobby.selectedMapType)
        XCTAssertNotNil(lobby.lobbyId)
    }

    func testInitializationWithSelectedMap() {
        lobby = Lobby(
            lobbyId: "12345",
            hostId: "abcdefghi",
            lobbyState: .open,
            selectedMapType: .CannotDieMap,
            playersId: [], costumesId: [:])
        XCTAssertEqual(lobby.hostId, "abcdefghi")
        XCTAssertEqual(lobby.playersId.count, 0)
        XCTAssertEqual(lobby.costumesId.count, 0)
        XCTAssertEqual(lobby.lobbyState, LobbyState.open)
        XCTAssertEqual(lobby.selectedMapType, MapType.CannotDieMap)
        XCTAssertEqual(lobby.lobbyId, "12345")
    }

    func testAddPlayerLessThanMaxPlayer() {
        lobby = Lobby(hostId: "abcdefghi")
        lobby.addPlayer(playerId: "1234")
        lobby.addPlayer(playerId: "2345")
        XCTAssertEqual(lobby.playersId.count, 3)
        XCTAssertEqual(lobby.lobbyState, LobbyState.open)
    }

    func testAddPlayerEqualMaxPlayer() {
        lobby = Lobby(hostId: "abcdefghi")
        lobby.addPlayer(playerId: "1234")
        lobby.addPlayer(playerId: "2345")
        lobby.addPlayer(playerId: "3345")
        XCTAssertEqual(lobby.playersId.count, 4)
        XCTAssertEqual(lobby.lobbyState, LobbyState.full)
    }

    func testAddPlayerMoreThanMaxPlayer() {
        lobby = Lobby(hostId: "abcdefghi")
        lobby.addPlayer(playerId: "1234")
        lobby.addPlayer(playerId: "2345")
        lobby.addPlayer(playerId: "3345")
        lobby.addPlayer(playerId: "4345")
        XCTAssertEqual(lobby.playersId.count, 4)
        XCTAssertEqual(lobby.lobbyState, LobbyState.full)
    }

    func testUpdateCustomeIdPlayerExists() {
        lobby = Lobby(hostId: "abcdefghi")
        lobby.addPlayer(playerId: "1234")
        lobby.addPlayer(playerId: "2345")
        XCTAssertEqual(lobby.playersId.count, 3)
        XCTAssertEqual(lobby.lobbyState, LobbyState.open)

        lobby.updateCostumeId(playerId: "1234", costumeType: .Dude_Monster)
        XCTAssertEqual(lobby.costumesId["1234"], CostumeType.Dude_Monster)
    }

    func testUpdateCustomeIdPlayerDoNotExists() {
        lobby = Lobby(hostId: "abcdefghi")
        lobby.addPlayer(playerId: "1234")
        lobby.addPlayer(playerId: "2345")
        XCTAssertEqual(lobby.playersId.count, 3)
        XCTAssertEqual(lobby.lobbyState, LobbyState.open)

        lobby.updateCostumeId(playerId: "12345", costumeType: .Dude_Monster)
        XCTAssertNil(lobby.costumesId["12345"])
    }

    func testUpdateSelectedMapType() {
        lobby = Lobby(
            lobbyId: "12345",
            hostId: "abcdefghi",
            lobbyState: .open,
            selectedMapType: .CannotDieMap,
            playersId: [], costumesId: [:])
        XCTAssertEqual(lobby.hostId, "abcdefghi")
        XCTAssertEqual(lobby.playersId.count, 0)
        XCTAssertEqual(lobby.costumesId.count, 0)
        XCTAssertEqual(lobby.lobbyState, LobbyState.open)
        XCTAssertEqual(lobby.selectedMapType, MapType.CannotDieMap)
        XCTAssertEqual(lobby.lobbyId, "12345")

        lobby.updateSelectedMapType(selectedMapType: .DeadlockMap)
        XCTAssertEqual(lobby.selectedMapType, MapType.DeadlockMap)
    }
}
