//
//  HookActionData.swift
//  Hookies
//
//  Created by Jun Wei Koh on 26/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SocketIO

struct HookActionData: SocketData, Encoder {
    var encoding: [String: Any] {
        return defaultEncoding()
    }

    let playerId: String
    let position: CGPoint
    var velocity: CGVector?
    let actionType: HookActionType

    init(player: Player, type: HookActionType) {
        self.playerId = player.id
        self.position = player.node.position
        self.velocity = player.node.physicsBody?.velocity
        self.actionType = type
    }

    init(playerId: String, position: CGPoint, velocity: CGVector?, type: HookActionType) {
        self.playerId = playerId
        self.position = position
        self.velocity = velocity
        self.actionType = type
    }

    init?(data: DictionaryModel) {
        do {
            self.playerId = try data.value(forKey: "playerId")
            guard let actionType = HookActionType(rawValue: try data.value(forKey: "actionType")) else {
                return nil
            }
            self.actionType = actionType
            self.position = CGPoint(x: try data.value(forKey: "positionX") as Double,
                                    y: try data.value(forKey: "positionY") as Double)
            if let velocityX: Double = data.optionalValue(forKey: "velocityX"),
                let velocityY: Double = data.optionalValue(forKey: "velocityY") {
                    self.velocity = CGVector(dx: velocityX, dy: velocityY)
            }
        } catch {
            return nil
        }
    }

    func socketRepresentation() -> SocketData {
        return encoding
    }
}

enum HookActionType: String, CaseIterable, StringRepresentable {
    case activate, deactivate

    var stringValue: String {
        return self.rawValue
    }
}
