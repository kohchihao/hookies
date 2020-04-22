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
}

class BotSystem: System, BotSystemProtocol {
    
    private var bots = [SpriteComponent : BotComponent]()
    weak var delegate: BotSystemDelegate?
    private var timer: Timer?
    private var timeElapsed: Double = 0
    
    init(bots: [SpriteComponent : BotComponent]) {
        self.bots = bots
        
        registerNotificationObservers()
    }

    func start() {
        self.timer = Timer.scheduledTimer(timeInterval: Constants.botTimeStep, target: self, selector: #selector(emit), userInfo: nil, repeats: true)
    }

    @objc private func emit() {
        for bot in bots {
            guard let instruction = bot.value.getNextInstruction(timeElapsed: timeElapsed) else {
                continue
            }
            broadcast(with: bot.key, of: instruction.action)
        }
        self.timeElapsed += Constants.botTimeStep
    }

    func stop() {
        self.timer?.invalidate()
        self.timer = nil
    }

    func add(spriteComponent: SpriteComponent, botComponent: BotComponent) {
        self.bots[spriteComponent] = botComponent
    }

    private func broadcast(with sprite: SpriteComponent, of eventType: GenericPlayerEvent) {
        let genericSystemEvent = GenericSystemEvent(sprite: sprite, eventType: eventType)
        NotificationCenter.default.post(
            name: .broadcastGenericPlayerAction,
            object: self,
            userInfo: ["data": genericSystemEvent])
    }
}

extension BotSystem {
    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedGameStartEvent(_:)),
            name: .receivedReachedFinishLineAction,
            object: nil)
    }

    @objc private func receivedGameStartEvent(_ notification: Notification) {
        
    }
}
