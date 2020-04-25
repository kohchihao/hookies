//
//  BotSystem.swift
//  Hookies
//
//  Created by Tan LongBin on 20/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

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

    func stopBot(botSprite: SpriteComponent) {
        self.bots = self.bots.filter({ $0.key != botSprite })
    }

    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }

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

    private func broadcast(with sprite: SpriteComponent, of eventType: GenericPlayerEvent) {
        let genericSystemEvent = GenericSystemEvent(sprite: sprite, eventType: eventType)
        NotificationCenter.default.post(
            name: .broadcastGenericPlayerAction,
            object: self,
            userInfo: ["data": genericSystemEvent])
    }

    private func broadcastJoin(with sprite: SpriteComponent) {
        NotificationCenter.default.post(
            name: .broadcastBotJoinEvent,
            object: self,
            userInfo: ["data": sprite])
    }

    @objc private func broadcastGameConnectedEvent(_ notification: Notification) {
        for (sprite, _) in bots {
            broadcastJoin(with: sprite)
        }
    }
}
