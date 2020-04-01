//
//  HookActionData.swift
//  Hookies
//
//  Created by Jun Wei Koh on 26/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SocketIO

class HookActionData: SocketData, Encoder {
    let actionType: HookActionType
    let playerData: PlayerData

    var encoding: [String: Any] {
        var defaultEncoding: [String: Any] = ["actionType": actionType.rawValue]
        defaultEncoding.merge(playerData.encoding) { _, new in new }
        return defaultEncoding
    }

    init(playerId: String, position: CGPoint, velocity: CGVector?, type: HookActionType) {
        self.actionType = type
        self.playerData = PlayerData(playerId: playerId, position: position, velocity: velocity)
    }

    init?(data: DictionaryModel) {
        do {
            guard let actionType = HookActionType(rawValue: try data.value(forKey: "actionType")),
                let playerData = PlayerData(data: data) else {
                return nil
            }
            self.actionType = actionType
            self.playerData = playerData
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
