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
    
    init(bots: [SpriteComponent : BotEntity]) {
        
        
        registerNotificationObservers()
    }

    func start() {
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(emit), userInfo: nil, repeats: true)
    }

    @objc private func emit() {
        for bot in bots {
            guard let action = bot.value.instruction.first else {
                return
            }
            broadcast(with: bot.key, of: action)
        }
        
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
