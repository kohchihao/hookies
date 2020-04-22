//
//  GameEngineDelegate.swift
//  Hookies
//
//  Created by JinYing on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

protocol GameEngineDelegate: AnyObject {
    func startCountdown()
    func playerDidHook(to hook: HookDelegateModel)
    func playerDidUnhook(from hook: HookDelegateModel)
    func playerIsStuck()
    func playerHasFinishRace()
    func playerHookToPlayer(with line: SKShapeNode)
    func addCurrentPlayer(with sprite: SKSpriteNode)
    func addPlayer(with sprite: SKSpriteNode)
    func currentPlayerIsReconnected()
    func currentPlayerIsDisconnected()
    func gameHasFinish(rankings: [Player])
    func addNotActivatedPowerup(_ sprite: SKSpriteNode)
    func addTrap(with sprite: SKSpriteNode)
    func movementButton(isDisabled: Bool)
    func hasPowerupStolen(powerup: PowerupType)
    func hasStolen(powerup: PowerupType)
}
