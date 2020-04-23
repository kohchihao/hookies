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
    func stop()
    func add(spriteComponent: SpriteComponent, botComponent: BotComponent)
}

class BotSystem: System, BotSystemProtocol {

    private(set) var bots = [SpriteComponent: BotComponent]()
    weak var delegate: BotSystemDelegate?
    private var timer: Timer?
    private var timeElapsed: Double = 0

    init() {
        print("bot system created")
    }

    // swiftlint:disable line_length

    func start() {
        self.timer = Timer.scheduledTimer(timeInterval: Constants.botTimeStep, target: self, selector: #selector(update), userInfo: nil, repeats: true)
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
        broadcast(with: botSprite, of: .reachedFinishedLine)
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
