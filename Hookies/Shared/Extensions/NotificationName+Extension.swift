//
//  NotificationName+Extension.swift
//  Hookies
//
//  Created by JinYing on 14/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

extension Notification.Name {
    // MARK: - Systems to NetworkManager
    static let gameConnectionEvent = Notification.Name("gameConnectionEvent")
    static let addPlayersMapping = Notification.Name("addPlayersMapping")
    static let broadcastGenericPlayerAction = Notification.Name("broadcastGenericPlayerAction")
    static let broadcastPowerupCollectionEvent = Notification.Name("broadcastPowerupCollectionEvent")
    static let broadcastPowerupAction = Notification.Name("broadcastPowerupAction")
    static let broadcastFinishGameEvent = Notification.Name("broadcastFinishGameEvent")

    // MARK: - NetworkManager to Systems

    // Start
    static let receivedOtherPlayerJoinEvent = Notification.Name("receivedOtherPlayerJoinEvent")

    // UserConnection
    static let receivedOtherPlayerDisconnectedEvent = Notification.Name("receivedOtherPlayerDisconnectedEvent")
    static let receivedOtherPlayerRejoinEvent = Notification.Name("receivedOtherPlayerRejoinEvent")
    static let receivedCurrentPlayerRejoinEvent = Notification.Name("receivedCurrentPlayerRejoinEvent")
    static let receivedCurrentPlayerDisconnectedEvent = Notification.Name("receivedCurrentPlayerDisconnectedEvent")

    // Hook
    static let receivedHookAction = Notification.Name("receivedHookAction")
    static let receivedUnookAction = Notification.Name("receivedUnookAction")
    static let receivedShortenRopeAction = Notification.Name("receivedShortenRopeAction")
    static let receivedLengthenRopeAction = Notification.Name("receivedLengthenRopeAction")
    static let receivedHookPlayerAction = Notification.Name("receivedHookPlayerAction")

    // Cannon
    static let receivedLaunchAction = Notification.Name("receivedLaunchAction")

    // Deadlock
    static let receivedJumpAction = Notification.Name("receivedJumpAction")

    // Health
    static let receivedRespawnAction = Notification.Name("receivedRespawnAction")

    // FinishingLine
    static let receivedReachedFinishLineAction = Notification.Name("receivedReachedFinishLineAction")

    // Powerup
    static let receviedPowerupCollectionEvent = Notification.Name("receivedPowerupCollectionEvent")
    static let receivedPowerupAction = Notification.Name("receivedPowerupAction")

    // End
    static let broadcastPlayerFinishSprite = Notification.Name("broadcastPlayerFinishSprite")
    static let receivedGameEndEvent = Notification.Name("receivedGameEndEvent")
}
