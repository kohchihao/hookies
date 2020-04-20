//
//  NetworkManager.swift
//  Hookies
//
//  Created by JinYing on 12/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit
import Network

/// Handles Network Communications

protocol NetworkManagerProtocol {
    func set(gameId: String)
}

class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()

    private(set) var gameId: String?
    private(set) var currentPlayerId: String?
    private(set) var deviceStatus: DeviceStatus?
    private var otherPlayersId = Set<String>()
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(broadcastPowerupCollection(_:)),
            name: .broadcastPowerupCollectionEvent,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(broadcastFinishGame(_:)),
            name: .broadcastFinishGameEvent,
            object: nil)
    }

    // MARK: - Game Connection

    @objc private func gameConnection(_ notification: Notification) {
        guard let gameId = gameId else {
            print("NetworkManager - GameConnection: gameId is nil")
            return
        }

        print("NetworkManager - GameConnection: Connecting to game...")
        API.shared.gameplay.connect(roomId: gameId, completion: { otherPlayersId in
            print("NetworkManager - GameConnection: Connected to game")
            for otherPlayerId in otherPlayersId {
                self.handleOtherPlayerJoinEvent(with: otherPlayerId)
            }

            self.setupSocketSubscriptions()
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

        return GenericPlayerEventData(
            playerId: currentPlayerId,
            position: position,
            velocity: velocity,
            type: playerAction.eventType)
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

    // MARK: - Broadcast Powerup Collection

    @objc private func broadcastPowerupCollection(_ notification: Notification) {
        if let data = notification.userInfo as? [String: PowerupCollectionSystemEvent] {
            guard let powerupCollectionSystemEvent = data["data"] else {
                return
            }

            guard let powerupCollectionData = createPowerupCollectionData(from: powerupCollectionSystemEvent) else {
                return
            }

            API.shared.gameplay.broadcastPowerupCollection(powerupCollection: powerupCollectionData)
        }
    }

    private func createPowerupCollectionData(
        from powerupCollectionSystemEvent: PowerupCollectionSystemEvent
    ) -> PowerupCollectionData? {
        guard let currentPlayerId = currentPlayerId else {
            print("NetworkManager - createPowerupCollectionData: currentPlayerId is nil")
            return nil
        }

        return PowerupCollectionData(
            playerId: currentPlayerId,
            node: powerupCollectionSystemEvent.sprite.node,
            powerupPosition: powerupCollectionSystemEvent.powerupPos,
            powerupType: powerupCollectionSystemEvent.powerupType)
    }

    // MARK: - Broadcast Finish Game

    @objc private func broadcastFinishGame(_ notification: Notification) {
        API.shared.gameplay.registerFinishLineReached()

        guard let deviceStatus = deviceStatus else {
            return
        }

        if deviceStatus == .offline {
            if let data = notification.userInfo as? [String: SpriteComponent] {
                guard let sprite = data["data"] else {
                    return
                }

                NotificationCenter.default.post(
                    name: .broadcastPlayerFinishSprite,
                    object: self,
                    userInfo: ["data": sprite])
            }
        }
    }

    // MARK: - Socket Subscriptions

    private func setupSocketSubscriptions() {
        subscribeToRoomConnection()
        subscribeToOtherPlayersState()
        subscribeToGenericPlayerEvent()
        subscribeToGameEndEvent()
        subscribeToPowerupCollection()
        subscribeToPowerupEvent()
    }

    // MARK: Room Connection (Current Player Connection)

    private func subscribeToRoomConnection() {
        guard let gameId = gameId, let deviceStatus = deviceStatus else {
            return
        }

        guard deviceStatus == .online else {
            return
        }

        API.shared.gameplay.subscribeToRoomConnection(roomId: gameId, listener: { connectionState in
            switch connectionState {
            case .connected:
                NotificationCenter.default.post(name: .receivedCurrentPlayerRejoinEvent, object: self)
            case .disconnected:
                NotificationCenter.default.post(name: .receivedCurrentPlayerDisconnectedEvent, object: self)
            }
        })
    }

    // MARK: Player Connection State

    private func subscribeToOtherPlayersState() {
        API.shared.gameplay.subscribeToPlayersConnection(listener: { userConnection in
            switch userConnection.state {
            case .connected:
                let isNewUser = !self.otherPlayersId.contains(userConnection.uid)

                if isNewUser {
                    self.handleOtherPlayerJoinEvent(with: userConnection.uid)
                } else {
                    guard let otherPlayerSprite = self.playersSprite[userConnection.uid] else {
                        return
                    }

                    NotificationCenter.default.post(
                        name: .receivedOtherPlayerRejoinEvent,
                        object: self,
                        userInfo: ["data": otherPlayerSprite])
                }
            case .disconnected:
                guard let otherPlayerSprite = self.playersSprite[userConnection.uid] else {
                    return
                }

                NotificationCenter.default.post(
                    name: .receivedOtherPlayerDisconnectedEvent,
                    object: self,
                    userInfo: ["data": otherPlayerSprite])
            }
        })
    }

    // MARK: Generic Player Event

    private func subscribeToGenericPlayerEvent() {
        API.shared.gameplay.subscribeToGenericPlayerEvent(listener: { genericPlayerEventData in
            guard let genericSystemEvent = self.createGenericSystemEvent(from: genericPlayerEventData) else {
                return
            }

            let notificationData = ["data": genericSystemEvent]
            var name: Notification.Name
            switch genericPlayerEventData.type {
            case .shotFromCannon:
                name = .receivedLaunchAction
            case .jumpAction:
                name = .receivedJumpAction
            case .playerDied:
                name = .receivedRespawnAction
            case .reachedFinishedLine:
                name = .receivedReachedFinishLineAction
            case .hook:
                name = .receivedHookAction
            case .unhook:
                name = .receivedUnookAction
            case .lengthenRope:
                name = .receivedLengthenRopeAction
            case .shortenRope:
                name = .receivedShortenRopeAction
            }
            NotificationCenter.default.post(name: name, object: self, userInfo: notificationData)
        })
    }

    private func createGenericSystemEvent(from genericPlayerEventData: GenericPlayerEventData) -> GenericSystemEvent? {
        let playerId = genericPlayerEventData.playerData.playerId

        guard let playerSprite = playersSprite[playerId] else {
            print("NetworkManager - CreateGenericSystemEvent: No player sprite of \(playerId) and event \(genericPlayerEventData.type)")
            return nil
        }

        guard let velocity = genericPlayerEventData.playerData.velocity else {
            return nil
        }

        playerSprite.node.position = CGPoint(vector: genericPlayerEventData.playerData.position)
        playerSprite.node.physicsBody?.velocity = CGVector(vector: velocity)

        return GenericSystemEvent(sprite: playerSprite, eventType: genericPlayerEventData.type)
    }

    // MARK: Game end

    private func subscribeToGameEndEvent() {
        API.shared.gameplay.subscribeToGameEndEvent(listener: { rankings in
            var rankingsSprite = [SpriteComponent]()

            for userId in rankings {
                guard let playerSprite = self.playersSprite[userId] else {
                    return
                }

                rankingsSprite.append(playerSprite)
            }

            NotificationCenter.default.post(
                name: .receivedGameEndEvent,
                object: self,
                userInfo: ["data": rankingsSprite])
        })
    }

    // MARK: Powerup Action

    private func subscribeToPowerupEvent() {
        API.shared.gameplay.subscribeToPowerupEvent(listener: { powerupEventData in
            guard let powerupSystemEvent = self.createPowerupSystemEvent(from: powerupEventData) else {
                return
            }

            NotificationCenter.default.post(
                name: .receivedPowerupAction,
                object: self,
                userInfo: ["data": powerupSystemEvent])
        })
    }

    private func createPowerupSystemEvent(from powerupEventData: PowerupEventData) -> PowerupSystemEvent? {
        let playerId = powerupEventData.playerData.playerId

        guard let playerSprite = playersSprite[playerId] else {
            print("NetworkManager - createPowerupSystemEvent: No player sprite of \(playerId)")
            return nil
        }

        playerSprite.node.position = CGPoint(vector: powerupEventData.playerData.position)

        return PowerupSystemEvent(
            sprite: playerSprite,
            powerupEventType: powerupEventData.eventType,
            powerupPos: powerupEventData.eventPos,
            powerupType: powerupEventData.type)
    }

    // MARK: Powerup Collection

    private func subscribeToPowerupCollection() {
        API.shared.gameplay.subscribeToPowerupCollection(listener: { collectionData in
            guard let powerupCollectionSystemEvent = self.createPowerCollectionSystemEvent(from: collectionData) else {
                return
            }

            NotificationCenter.default.post(
                name: .receviedPowerupCollectionEvent,
                object: self,
                userInfo: ["data": powerupCollectionSystemEvent])
        })
    }

    private func createPowerCollectionSystemEvent(
        from powerupCollectionData: PowerupCollectionData
    ) -> PowerupCollectionSystemEvent? {
        let playerId = powerupCollectionData.playerData.playerId

        guard let playerSprite = playersSprite[playerId] else {
            print("NetworkManager - createPowerCollectionSystemEvent: No player sprite of \(playerId)")
            return nil
        }

        playerSprite.node.position = CGPoint(vector: powerupCollectionData.playerData.position)

        return PowerupCollectionSystemEvent(
            sprite: playerSprite,
            powerupPos: powerupCollectionData.powerupPos,
            powerupType: powerupCollectionData.type)
    }

    // MARK: - Other Player Join Event Handler

    private func handleOtherPlayerJoinEvent(with playerId: String) {
        NotificationCenter.default.post(name: .receivedOtherPlayerJoinEvent, object: nil)

        otherPlayersId.insert(playerId)
    }
}
