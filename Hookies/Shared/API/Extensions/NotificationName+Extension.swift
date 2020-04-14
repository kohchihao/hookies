//
//  NotificationName+Extension.swift
//  Hookies
//
//  Created by JinYing on 14/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

extension Notification.Name {
    // Systems to NetworkManager
    static let receiveGameConnectionEvent = Notification.Name("receiveGameConnectionEvent")
    static let receiveAddPlayersMapping = Notification.Name("receiveAddPlayersMapping")
    static let broadcastGenericPlayerAction = Notification.Name("broadcastGenericPlayerAction")
    static let broadcastPowerupAction = Notification.Name("broadcastPowerupAction")

    // NetworkManager to Systems
    static let receivedOtherPlayerJoinEvent = Notification.Name("receivedOtherPlayerJoinEvent")
    static let receivedOtherPlayerDisconnectedEvent = Notification.Name("receivedOtherPlayerDisconnectedEvent")
    static let receivedOtherPlayerRejoinEvent = Notification.Name("receivedOtherPlayerRejoinEvent")
    static let receivedHookAction = Notification.Name("receivedHookAction")
    static let receivedUnookAction = Notification.Name("receivedUnookAction")
    static let receivedShortenRopeAction = Notification.Name("receivedShortenRopeAction")
    static let receivedLengthenRopeAction = Notification.Name("receivedLengthenRopeAction")
    static let receivedLaunchAction = Notification.Name("receivedLaunchAction")
    static let receivedJumpAction = Notification.Name("receivedJumpAction")
    static let receivedRespawnAction = Notification.Name("receivedRespawnAction")
    static let receivedReachedFinishLineAction = Notification.Name("receivedReachedFinishLineAction")
    static let receviedPowerupCollectionEvent = Notification.Name("receivedPowerupCollectionEvent")
    static let receivedPowerupAction = Notification.Name("receivedPowerupAction")
}
