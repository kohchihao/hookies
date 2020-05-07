//
//  PlayerDependencyProtocol.swift
//  Hookies
//
//  Created by Jun Wei Koh on 6/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol PlayerDependencyProtocol {
    var players: [SpriteComponent] { get set }
}

extension PlayerDependencyProtocol {
    mutating func add(player: SpriteComponent) {
        players.append(player)
    }
}
