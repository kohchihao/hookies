//
//  Powerup+FirestoreRepresentable.swift
//  Hookies
//
//  Created by Jun Wei Koh on 17/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

extension Powerup where Self: FirestoreRepresentable {
    var representation: [String: Any?] {
        return [
            "isPowerupActivated": isActivated,
            "powerupName": Self.name,
            "powerupOwnerId": ownerId
        ]
    }
}
