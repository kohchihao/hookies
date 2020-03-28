//
//  Powerup+DictionaryRepresentable.swift
//  Hookies
//
//  Created by Jun Wei Koh on 17/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

extension Powerup where Self: DictionaryRepresentable {
    var representation: [String: Any] {
        return [
            "isPowerupActivated": isActivated,
            "powerupName": Self.name,
            "powerupOwnerId": ownerId ?? ""
        ]
    }
}
