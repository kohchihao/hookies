//
//  GenericPlayerEvent.swift
//  Hookies
//
//  Created by Jun Wei Koh on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

enum GenericPlayerEvent: String, CaseIterable, StringRepresentable {
    case reachedFinishedLine, shotFromCannon, jumpAction, playerDied

    var stringValue: String {
        return self.rawValue
    }
}
