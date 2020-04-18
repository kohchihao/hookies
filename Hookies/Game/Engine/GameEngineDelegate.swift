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
    func addPlayer(with sprite: SKSpriteNode)
    func currentPlayerIsReconnected()
    func currentPlayerIsDisconnected()
    func gameHasFinish()
    func addNotActivatedPowerup(_ sprite: SKSpriteNode)
    func addTrap(with sprite: SKSpriteNode)
}
