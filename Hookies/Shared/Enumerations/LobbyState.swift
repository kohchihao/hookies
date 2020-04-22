//
//  LobbyState.swift
//  Hookies
//
//  Created by Jun Wei Koh on 20/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

enum LobbyState: String, CaseIterable {
    case open
    case full
    case start
    case empty
}

extension LobbyState: StringRepresentable {
    var stringValue: String {
        return self.rawValue
    }
}
