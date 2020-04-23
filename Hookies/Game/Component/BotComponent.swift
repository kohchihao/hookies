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
    var instructions: [BotInstruction]

    init(parent: Entity, instructions: [BotInstruction]) {
        self.parent = parent
        self.instructions = instructions
    }

    func getNextInstruction(timeElapsed: Double) -> BotInstruction? {
        let nextInstruction = instructions.first
        guard let instructionTimeStep = nextInstruction?.timeSteps else {
            return nil
        }
        guard Double(instructionTimeStep) * Constants.botTimeStep <= timeElapsed else {
            return nil
        }
        self.instructions.removeFirst()
        return nextInstruction
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
