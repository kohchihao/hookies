//
//  BotComponent.swift
//  Hookies
//
//  Created by Tan LongBin on 20/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class BotComponent: Component {
    private(set) var parent: Entity
    var instruction: [GenericPlayerEvent]

    init(parent: Entity, instruction: [GenericPlayerEvent]) {
        self.parent = parent
        self.instruction = instruction
    }
}

// MARK: - Hashable
extension BotComponent: Hashable {
    static func == (lhs: BotComponent, rhs: BotComponent) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
}
