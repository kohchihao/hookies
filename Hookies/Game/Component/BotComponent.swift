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


    /// Get the next instruction for the bot.
    /// - Parameter timeElapsed: The time elapsed
    func getNextInstruction(timeElapsed: Double) -> BotInstruction? {
        guard let nextInstruction = instructions.first else {
            return nil
        }
        let instructionTimeStep = nextInstruction.timeSteps
        guard Double(instructionTimeStep) * Constants.botTimeStep <= timeElapsed else {
            return nil
        }

        var repeatedInstruction = nextInstruction
        repeatedInstruction.timeSteps += Int(Constants.maxGameLength / Constants.botTimeStep)
        self.instructions.append(repeatedInstruction)
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
