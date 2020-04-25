//
//  HookDelegateModel.swift
//  Hookies
//
//  Created by JinYing on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//
import SpriteKit

/// Represent the required fields for hook's components
/// - Parameters:
///     - line: line to the attached bolt
///     - anchorLineJointPin: joint pin from the attahed bolt to the line
///     - playerLineJointPin: joint pin from the player to the line
struct HookDelegateModel {
    let line: SKShapeNode
    let anchorLineJointPin: SKPhysicsJointPin
    let playerLineJointPin: SKPhysicsJointPin
}
