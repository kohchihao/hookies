//
//  EndSystem.swift
//  Hookies
//
//  Created by JinYing on 20/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

/// End systems helps to check if the game has ended.

protocol EndSystemProtocol {

}

protocol EndSystemDelegate: AnyObject {
    /// Indicates that the game has ended.
    /// - Parameter rankings: The ranking of the players
    func gameEnded(rankings: [Player])
}

class EndSystem: System, EndSystemProtocol {

    private var totalNumberOfPlayers: Int

    private var rankings = [SpriteComponent]()
    weak var delegate: EndSystemDelegate?

    init(totalPlayers: Int) {
        totalNumberOfPlayers = totalPlayers
        Logger.log.show(details: "Total: \(totalPlayers)", logType: .alert)
        registerNotificationObservers()
    }
}

// MARK: - Networking

extension EndSystem {
    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(
           self,
           selector: #selector(broadcastPlayerFinishSprite(_:)),
           name: .broadcastPlayerFinishSprite,
           object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedGameEndEvent(_:)),
            name: .receivedGameEndEvent,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(broadcastUnregisterObserver(_:)),
            name: .broadcastUnregisterObserver,
            object: nil)
    }

    @objc private func broadcastPlayerFinishSprite(_ notification: Notification) {
        if let data = notification.userInfo as? [String: SpriteComponent] {
            guard let playerSprite = data["data"] else {
                return
            }

            guard rankings.count < totalNumberOfPlayers else {
                return
            }

            rankings.append(playerSprite)

            let hasAllRankings = rankings.count == totalNumberOfPlayers
            if hasAllRankings {
                NotificationCenter.default.post(
                name: .broadcastPlayerRankings,
                object: self,
                userInfo: ["data": rankings])
            }
        }
    }

    @objc private func receivedGameEndEvent(_ notification: Notification) {
        if let data = notification.userInfo as? [String: [Player]] {
            guard let rankings = data["data"] else {
                return
            }

            Logger.log.show(details: "Recevied End Game Event", logType: .information)

            delegate?.gameEnded(rankings: rankings)
        }
    }

    @objc private func broadcastUnregisterObserver(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
    }
}
