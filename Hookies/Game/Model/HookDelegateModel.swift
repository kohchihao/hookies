//
//  HookDelegateModel.swift
//  Hookies
//
//  Created by JinYing on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//
import SpriteKit

struct HookDelegateModel {
    let line: SKShapeNode
    let anchorLineJointPin: SKPhysicsJointPin
    let playerLineJointPin: SKPhysicsJointPin

    init(
        line: SKShapeNode,
        anchorLineJointPin: SKPhysicsJointPin,
        playerLineJointPin: SKPhysicsJointPin
    ) {
        self.line = line
        self.anchorLineJointPin = anchorLineJointPin
        self.playerLineJointPin = playerLineJointPin
    }
}
