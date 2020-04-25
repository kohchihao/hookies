//
//  BotSystem.swift
//  Hookies
//
//  Created by Tan LongBin on 20/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

/// Bot System manages the bot along with its instructions.

protocol BotSystemDelegate: class {

}

protocol BotSystemProtocol {
    func start()
    func stopTimer()
    func add(spriteComponent: SpriteComponent, botComponent: BotComponent)
}

class BotSystem: System, BotSystemProtocol {

    private(set) var bots = [SpriteComponent: BotComponent]()
    weak var delegate: BotSystemDelegate?
    private var timer: Timer?
    private var timeElapsed: Double = 0

    init() {
        Logger.log.show(details: "bot system created", logType: .information)
        registerNotificationObservers()
    }


    /// Start the timer for the bot system.
    func start() {
        self.timer = Timer.scheduledTimer(
            timeInterval: Constants.botTimeStep,
            target: self,
            selector: #selector(update),
            userInfo: nil,
            repeats: true)
    }

    @objc private func update() {
        for bot in bots {
            guard let instruction = bot.value.getNextInstruction(timeElapsed: timeElapsed) else {
                continue
            }
            broadcast(with: bot.key, of: instruction.action)
        }
        self.timeElapsed += Constants.botTimeStep
    }

    /// Stop the bot entirely.
    /// - Parameter botSprite: The sprite of the bot
    func stopBot(botSprite: SpriteComponent) {
        self.bots = self.bots.filter({ $0.key != botSprite })
        broadcast(with: botSprite, of: .reachedFinishedLine)
        broadcastBotEvent(with: botSprite, of: .broadcastBotGameEndEvent)
    }

    /// Stop the timer for the bot system.
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }

    /// Add the bot's sprite to the system
    /// - Parameters:
    ///   - spriteComponent: The sprite of the bot
    ///   - botComponent: The bot component
    func add(spriteComponent: SpriteComponent, botComponent: BotComponent) {
        self.bots[spriteComponent] = botComponent
    }
}

// MARK: Networking

extension BotSystem {
    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(broadcastGameConnectedEvent(_:)),
            name: .broadcastGameConnectedEvent,
            object: nil)
    }

    /// Broadcast to Notification center.
    private func broadcast(with sprite: SpriteComponent, of eventType: GenericPlayerEvent) {
        let genericSystemEvent = GenericSystemEvent(sprite: sprite, eventType: eventType)
        NotificationCenter.default.post(
            name: .broadcastGenericPlayerAction,
            object: self,
            userInfo: ["data": genericSystemEvent])
    }

    private func broadcastBotEvent(with sprite: SpriteComponent, of name: Notification.Name) {
        NotificationCenter.default.post(
            name: name,
            object: self,
            userInfo: ["data": sprite])
    }

    @objc private func broadcastGameConnectedEvent(_ notification: Notification) {
        for (sprite, _) in bots {
            broadcastBotEvent(with: sprite, of: .broadcastBotJoinEvent)
        }
    }
}
