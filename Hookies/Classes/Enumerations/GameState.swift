//
//  GameState.swift
//  Hookies
//
//  Created by Jun Wei Koh on 20/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

enum GameState: String, CaseIterable {
    case waiting
    case start
}

extension GameState: StringRepresentable {
    var stringValue: String {
        return rawValue
    }
}
