//
//  NetworkManager.swift
//  Hookies
//
//  Created by JinYing on 12/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit
import Network

protocol NetworkManagerProtocol {
    func set(gameId: String)
}

/// Handles Network Communications
/// - Parameters:
///     - gameId: The current game id
///     - currentPlayer: The current player of the device
///     - deviceStatus: The connection status of the device (online or offlne)
///     - otherPlayersId: A set of players id
///     - playersSprite: Mappings between all player's id to their SpriteComponent
///     - playersId: Mappings between all players's SpriteComponent to their id
///     - players: Mapping between all players id to their Player model

class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()

    private(set) var gameId: String?
    private(set) var currentPlayer: Player?
    private(set) var deviceStatus: DeviceStatus?
    private var otherPlayersId = Set<String>()
    private var playersSprite = [String: SpriteComponent]()
    private var playersId = [SpriteComponent: String]()
    private var players = [String: Player]()

    private init() {
        registerNotificationObservers()
        Logger.log.traceableFunctionName = true
    }

    /// Sets the gameId
    func set(gameId: String) {
        self.gameId = gameId
        setUpDeviceStatus()
    }

    // MARK: - Setup current device connection status

    private func setUpDeviceStatus() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "DeviceConnectionMonitor")

        monitor.pathUpdateHandler = { pathUpdateHandler in
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(broadcastPlayerRankings(_:)),
            name: .broadcastPlayerRankings,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(broadcastBotJoinEvent(_:)),
            name: .broadcastBotJoinEvent,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(broadcastBotGameEndEvent(_:)),
            name: .broadcastBotGameEndEvent,
            object: nil)

    }

    // MARK: - Game Connection

    @objc private func gameConnection(_ notification: Notification) {
        guard let gameId = gameId else {
            Logger.log.show(details: "gameId is nil", logType: .error)
            return
        }

        Logger.log.show(details: "Connecting to game...", logType: .information)
        API.shared.gameplay.connect(roomId: gameId, completion: { otherPlayersId in
            Logger.log.show(details: "Connected to game", logType: .information)
            for otherPlayerId in otherPlayersId {
                self.handleOtherPlayerJoinEvent(with: otherPlayerId)
            }

            self.setupSocketSubscriptions()

            NotificationCenter.default.post(name: .broadcastGameConnectedEvent, object: self)
        })

        if deviceStatus == .offline {
            NotificationCenter.default.post(name: .broadcastGameConnectedEvent, object: self)
        }
    }

    // MARK: - Add Players Mappings

    @objc private func addPlayerMappings(_ notification: Notification) {
        if let playersMapping = notification.userInfo as? [Player: SpriteComponent] {
            for (player, sprite) in playersMapping {
                playersSprite[player.playerId] = sprite
                players[player.playerId] = player
                playersId[sprite] = player.playerId

                if player.isCurrentPlayer {
                    currentPlayer = player
                }
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
            if genericPlayerEventData.playerData.playerId != currentPlayer?.playerId {
                let name = self.convertPlayerEventToNotificationName(playerEvent: genericPlayerEventData.type)
                NotificationCenter.default.post(name: name, object: self, userInfo: data)
            }
            API.shared.gameplay.boardcastGenericPlayerEvent(playerEvent: genericPlayerEventData)
        }
    }

    private func createPlayerEventData(from playerAction: GenericSystemEvent) -> GenericPlayerEventData? {
        guard let playerId = playersId[playerAction.sprite] else {
           Logger.log.show(details: "currentPlayerId is nil of \(playerAction.eventType)", logType: .error)
                        return nil
        }
        let position = Vector(point: playerAction.sprite.node.position)
        let velocity = Vector(vector: playerAction.sprite.node.physicsBody?.velocity)

        return GenericPlayerEventData(
            playerId: playerId,
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
        guard let playerId = playersId[powerupSystemEvent.sprite] else {
            Logger.log.show(details: "playerId is nil", logType: .error)
            return nil
        }

        return PowerupEventData(
            playerId: playerId,
            node: powerupSystemEvent.sprite.node,
            eventType: powerupSystemEvent.powerupEventType,
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
        guard let currentPlayerId = currentPlayer?.playerId else {
            Logger.log.show(details: "currentPlayerId is nil", logType: .error)
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

    // MARK: - Broadcast Player Rankings

    /// Handles the broadcast of the player rankings when the device is offline
    @objc private func broadcastPlayerRankings(_ notification: Notification) {
        if let data = notification.userInfo as? [String: [SpriteComponent]] {
            guard let rankings = data["data"] else {
                return
            }

            var playerRankings = [Player]()

            for ranking in rankings {
                guard let playerSpriteMapping = playersSprite.first(where: { $0.value == ranking }) else {
                    Logger.log.show(details: "Failed to get player sprite mapping", logType: .error)
                    return
                }

                guard let player = players[playerSpriteMapping.key] else {
                    return
                }

                playerRankings.append(player)
            }

            NotificationCenter.default.post(
                name: .receivedGameEndEvent,
                object: self,
                userInfo: ["data": playerRankings])
        }
    }

    // MARK: - Broadcast Bot Events

    @objc private func broadcastBotJoinEvent(_ notification: Notification) {
        if let data = notification.userInfo as? [String: SpriteComponent] {
            guard let sprite = data["data"] else {
                return
            }
            guard let gameId = gameId, let botId = playersId[sprite] else {
                return
            }

            API.shared.gameplay.botJoinRoom(roomId: gameId, userId: botId)
            NotificationCenter.default.post(name: .receivedOtherPlayerJoinEvent, object: nil)
        }
    }

    @objc private func broadcastBotGameEndEvent(_ notification: Notification) {
        if let data = notification.userInfo as? [String: SpriteComponent] {
            guard let sprite = data["data"] else {
                return
            }
            guard let botId = playersId[sprite] else {
                return
            }

            API.shared.gameplay.registerBotFinishLineReached(for: botId)
            broadcastOfflineFinishEvent(with: sprite)
        }
    }

    private func broadcastOfflineFinishEvent(with sprite: SpriteComponent) {
        guard let deviceStatus = deviceStatus else {
            return
        }

        if deviceStatus == .offline {
            NotificationCenter.default.post(
                name: .broadcastPlayerFinishSprite,
                object: self,
                userInfo: ["data": sprite])
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

    /// Listens to  the current player connection to the game
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

    /// Listens for  other players general game action.
    /// Includes: launchng, finishing, hooking, unhooking, jumping, respawing, lengthening and shortening of rope
    private func subscribeToGenericPlayerEvent() {
        API.shared.gameplay.subscribeToGenericPlayerEvent(listener: { genericPlayerEventData in
            guard let genericSystemEvent = self.createGenericSystemEvent(from: genericPlayerEventData) else {
                return
            }
            let notificationData = ["data": genericSystemEvent]
            let name = self.convertPlayerEventToNotificationName(playerEvent: genericPlayerEventData.type)
            NotificationCenter.default.post(name: name, object: self, userInfo: notificationData)
        })
    }

    private func convertPlayerEventToNotificationName(playerEvent: GenericPlayerEvent) -> Notification.Name {
        var name: Notification.Name
        switch playerEvent {
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
            name = .receivedUnhookAction
        case .lengthenRope:
            name = .receivedLengthenRopeAction
        case .shortenRope:
            name = .receivedShortenRopeAction
        }
        return name
    }

    private func createGenericSystemEvent(from genericPlayerEventData: GenericPlayerEventData) -> GenericSystemEvent? {
        let playerId = genericPlayerEventData.playerData.playerId

        guard let playerSprite = playersSprite[playerId] else {
            Logger.log.show(
                details: "No player sprite of \(playerId) and event \(genericPlayerEventData.type)",
                logType: .error)
            return nil
        }

        playerSprite.node.physicsBody?.isDynamic = true
        sync(sprite: playerSprite, with: genericPlayerEventData.playerData)

        return GenericSystemEvent(sprite: playerSprite, eventType: genericPlayerEventData.type)
    }

    // MARK: Game end

    private func subscribeToGameEndEvent() {
        API.shared.gameplay.subscribeToGameEndEvent(listener: { rankings in
            API.shared.gameplay.close()
            Logger.log.show(details: "Closed Game Connection", logType: .information)

            var playerRankings = [Player]()

            for userId in rankings {
                guard let player = self.players[userId] else {
                    return
                }

                playerRankings.append(player)
            }

            NotificationCenter.default.post(
                name: .receivedGameEndEvent,
                object: self,
                userInfo: ["data": playerRankings])

            NotificationCenter.default.post(name: .broadcastUnregisterObserver, object: self)

            self.reset()
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
            Logger.log.show(details: "No player sprite of \(playerId)", logType: .error)
            return nil
        }

        sync(sprite: playerSprite, with: powerupEventData.playerData)
        return PowerupSystemEvent(
            sprite: playerSprite,
            powerupEventType: powerupEventData.eventType,
            powerupPos: powerupEventData.eventPos)
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
            Logger.log.show(details: "No player sprite of \(playerId)", logType: .error)
            return nil
        }

        sync(sprite: playerSprite, with: powerupCollectionData.playerData)
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

    // MARK: - Sync with PlayerData

    private func sync(sprite: SpriteComponent, with data: PlayerData) {
        sprite.node.position = CGPoint(vector: data.position)
        guard let velocity = data.velocity else {
            return
        }
        sprite.node.physicsBody?.velocity = CGVector(vector: velocity)
    }

    // MARK: - Reset Network Manger

    /// Resets all of Network Manager's fields
    private func reset() {
        gameId = nil
        currentPlayer = nil
        deviceStatus = nil
        otherPlayersId.removeAll()
        playersSprite.removeAll()
        players.removeAll()
        playersId.removeAll()
    }
}
