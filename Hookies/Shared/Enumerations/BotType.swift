//
//  BotType.swift
//  Hookies
//
//  Created by JinYing on 12/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

enum BotType: CaseIterable {
    case hooksALot
    case hooksLittle
    case hooksAndShorten
    case hooksAndLength

    static func getRandom() -> BotType? {
        BotType.allCases.randomElement()
    }
}
