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
    private(set) var deviceStatus: DeviceStatus?
    private var playersSprite = [String: SpriteComponent]()

    private init() {
        setUpDeviceStatus()
    }

    func set(gameId: String) {
        self.gameId = gameId
    }

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
}
