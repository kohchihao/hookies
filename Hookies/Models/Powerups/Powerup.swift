//
//  Powerup.swift
//  Hookies
//
//  Created by Jun Wei Koh on 16/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol Powerup: Nameable, FirestoreRepresentable {
    var ownerId: String? { get }
    var name: String { get }
    var isActivated: Bool { get }

    mutating func activate(by user: User)
    mutating func deactivate()
    mutating func apply(to gameplay: Gameplay)
}
