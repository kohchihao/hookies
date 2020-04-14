//
//  GenericPlayerEvent.swift
//  Hookies
//
//  Created by Jun Wei Koh on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

enum GenericPlayerEvent: String, CaseIterable, StringRepresentable {
    case reachedFinishedLine
    case shotFromCannon
    case jumpAction
    case playerDied
    case hook
    case unhook

    var stringValue: String {
        return self.rawValue
    }
}
