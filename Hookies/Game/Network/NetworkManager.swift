//
//  NetworkManager.swift
//  Hookies
//
//  Created by JinYing on 12/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Network

protocol NetworkManagerProtocol {
    func set(gameId: String)
}

class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()

    private(set) var gameId: String?
    private(set) var currentPlayerId: String?
    private(set) var deviceStatus: DeviceStatus?
    private var playersSprite = [String: SpriteComponent]()

    private init() {
        currentPlayerId = API.shared.user.currentUser?.uid
        setUpDeviceStatus()
        registerNotificationObservers()
    }

    func set(gameId: String) {
        self.gameId = gameId
    }

    // MARK: - Setup current device connection status

    private func setUpDeviceStatus() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "DeviceConnectionMonitor")

        monitor.pathUpdateHandler = { pathUpdateHandler in
            // To ensure that the device status is set only once
            guard self.deviceStatus == nil else {
                return
            }

            if pathUpdateHandler.status == .satisfied {
                self.deviceStatus = .online
            } else {
                self.deviceStatus = .offline
            }
        }

        monitor.start(queue: queue)
    }

    // MARK: - Register Notifications Observers

    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(gameConnection(_:)),
            name: .gameConnectionEvent,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(addPlayerMappings(_:)),
            name: .addPlayersMapping,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(broadcastGenericPlayerAction(_:)),
            name: .broadcastGenericPlayerAction,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(broadcastPowerup(_:)),
            name: .broadcastPowerupAction,
            object: nil)
    }

    // MARK: - Game Connection

    @objc private func gameConnection(_ notification: Notification) {
        guard let gameId = gameId else {
            print("NetworkManager - GameConnection: gameId is nil")
            return
        }

        API.shared.gameplay.connect(roomId: gameId, completion: { otherPlayersId in
            for _ in otherPlayersId {
                NotificationCenter.default.post(name: .receivedOtherPlayerJoinEvent, object: nil)
            }
        })
    }

    // MARK: - Add Players Mappings

    @objc private func addPlayerMappings(_ notification: Notification) {
        if let playersMapping = notification.userInfo as? [Player: SpriteComponent] {
            for (player, sprite) in playersMapping {
                playersSprite[player.playerId] = sprite
            }
        }
    }

    // MARK: - Broadcast Generic Player Event

    @objc private func broadcastGenericPlayerAction(_ notification: Notification) {
        if let data = notification.userInfo as? [String: GenericSystemEvent] {
            guard let genericPlayerAction = data["data"] else {
                return
            }

            guard let genericPlayerEventData = createPlayerEventData(from: genericPlayerAction) else {
                return
            }

            API.shared.gameplay.boardcastGenericPlayerEvent(playerEvent: genericPlayerEventData)
        }
    }

    private func createPlayerEventData(from playerAction: GenericSystemEvent) -> GenericPlayerEventData? {
        guard let currentPlayerId = currentPlayerId else {
            print("NetworkManager - CreatePlayerEventData: currentPlayerId is nil")
            return nil
        }

        let position = Vector(point: playerAction.sprite.node.position)
        let velocity = Vector(vector: playerAction.sprite.node.physicsBody?.velocity)

        return GenericPlayerEventData(playerId: currentPlayerId, position: position, velocity: velocity, type: playerAction.eventType)
    }

    // MARK: - Broadcast Powerup

    @objc private func broadcastPowerup(_ notification: Notification) {
        if let data = notification.userInfo as? [String: PowerupSystemEvent] {
            guard let powerupSystemEvent = data["data"] else {
                return
            }

            guard let powerupEventData = createPowerupEventData(from: powerupSystemEvent) else {
                return
            }

            API.shared.gameplay.broadcastPowerupEvent(powerupEvent: powerupEventData)
        }
    }

    private func createPowerupEventData(from powerupSystemEvent: PowerupSystemEvent) -> PowerupEventData? {
        guard let currentPlayerId = currentPlayerId else {
            print("NetworkManager - CreatePowerupEventData: currentPlayerId is nil")
            return nil
        }

        return PowerupEventData(
            playerId: currentPlayerId,
            node: powerupSystemEvent.sprite.node,
            eventType: powerupSystemEvent.powerupEventType,
            powerupType: powerupSystemEvent.powerupType,
            eventPos: powerupSystemEvent.powerupPos
        )
    }

    // TODO: Add Selector for Collection
}
