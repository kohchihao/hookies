//
//  BotInstruction.swift
//  Hookies
//
//  Created by Tan LongBin on 22/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

struct BotInstruction {
    var timeSteps: Int
    var action: GenericPlayerEvent

    static func getInstructions(botType: BotType) -> [BotInstruction] {
        var instructions: [BotInstruction] = []
        let maxTimeSteps = Int(Constants.maxGameLength / Constants.botTimeStep)

        func addHookInstruction(timeStep: Int, isHook: Bool) {
            var botInstruction: BotInstruction
            if isHook {
                botInstruction = BotInstruction(timeSteps: timeStep, action: .hook)
            } else {
                botInstruction = BotInstruction(timeSteps: timeStep, action: .unhook)
            }
            instructions.append(botInstruction)
        }

        func addChangeLengthInstruction(timeStep: Int, isShorten: Bool) {
            var botInstruction: BotInstruction
            if isShorten {
                botInstruction = BotInstruction(timeSteps: timeStep, action: .shortenRope)
            } else {
                botInstruction = BotInstruction(timeSteps: timeStep, action: .lengthenRope)
            }
            instructions.append(botInstruction)
        }

        switch botType {
        case .hooksALot:
            var isHook = true
            for timeStep in 1...maxTimeSteps {
                if timeStep.isMultiple(of: 10) {
                    instructions.append(BotInstruction(timeSteps: timeStep, action: .jumpAction))
                    continue
                }
                addHookInstruction(timeStep: timeStep, isHook: isHook)
                isHook.toggle()
            }
        case .hooksLittle:
            var isHook = true
            let timeStepInterval = 3
            for timeStep in 1...maxTimeSteps {
                if timeStep.isMultiple(of: 10) {
                    instructions.append(BotInstruction(timeSteps: timeStep, action: .jumpAction))
                    continue
                }
                guard timeStep.isMultiple(of: timeStepInterval) else {
                    continue
                }
                addHookInstruction(timeStep: timeStep, isHook: isHook)
                isHook.toggle()
            }
        case .hooksAndShorten:
            var isHook = true
            let hookInterval = 2
            for timeStep in 1...maxTimeSteps {
                if timeStep.isMultiple(of: 10) {
                    instructions.append(BotInstruction(timeSteps: timeStep, action: .jumpAction))
                    continue
                }
                guard timeStep.isMultiple(of: hookInterval) else {
                    addChangeLengthInstruction(timeStep: timeStep, isShorten: true)
                    continue
                }
                addHookInstruction(timeStep: timeStep, isHook: isHook)
                isHook.toggle()
            }
        case .hooksAndLength:
            var isHook = true
            let hookInterval = 2
            for timeStep in 1...maxTimeSteps {
                if timeStep.isMultiple(of: 10) {
                    instructions.append(BotInstruction(timeSteps: timeStep, action: .jumpAction))
                    continue
                }
                guard timeStep.isMultiple(of: hookInterval) else {
                    addChangeLengthInstruction(timeStep: timeStep, isShorten: false)
                    continue
                }
                addHookInstruction(timeStep: timeStep, isHook: isHook)
                isHook.toggle()
            }            
        }
        return instructions
    }
}
