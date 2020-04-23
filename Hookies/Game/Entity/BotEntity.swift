//
//  BotEntity.swift
//  Hookies
//
//  Created by Tan LongBin on 20/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

class BotEntity: Entity {
    var components: [Component]

    init(components: [Component]) {
        self.components = components
    }

    convenience init(botType: BotType) {
        self.init(components: [])

        let instruction = BotInstruction.getInstructions(botType: botType)
        let bot = BotComponent(parent: self, instructions: instruction)

        addComponent(bot)
    }
}
