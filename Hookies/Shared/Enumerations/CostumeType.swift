//
//  CostumeType.swift
//  Hookies
//
//  Created by Tan LongBin on 20/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

/// Represent the type of costume in the game
enum CostumeType: String, CaseIterable {
    case Pink_Monster
    case Owlet_Monster
    case Dude_Monster
    case Mask_Dude
    case Ninja_Frog
    case Pink_Man
    case Virtual_Guy

    /// Gets the default costume of the game (.Pink_Monster)
    static func getDefault() -> CostumeType? {
        CostumeType.allCases.first
    }

    /// Gets a random costume
    static func getRandom() -> CostumeType? {
        CostumeType.allCases.randomElement()
    }

    /// Gets the next costime from the current costume
    /// - Parameter currentCostume: the current costume type
    static func nextCostume(currentCostume: CostumeType?) -> CostumeType? {
        let costumes = CostumeType.allCases
        guard let currentCostume = currentCostume else {
            return costumes.first
        }
        let currentIndex = costumes.firstIndex(of: currentCostume) ?? 0
        var nextIndex = currentIndex + 1
        if !costumes.indices.contains(nextIndex) {
            nextIndex = 0
        }
        return costumes[nextIndex]
    }

    /// Gets the previous costume from the current costume
    /// - Parameter currentCostume: the current costume type
    static func prevCostume(currentCostume: CostumeType?) -> CostumeType? {
        let costumes = CostumeType.allCases
        guard let currentCostume = currentCostume else {
            return costumes.first
        }
        let currentIndex = costumes.firstIndex(of: currentCostume) ?? 0
        var prevIndex = currentIndex - 1
        if !costumes.indices.contains(prevIndex) {
            prevIndex = costumes.endIndex - 1
        }
        return costumes[prevIndex]
    }
}

extension CostumeType: StringRepresentable {
    /// The string value of the CostumeType
    var stringValue: String {
        return self.rawValue
    }
}
