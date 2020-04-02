//
//  GameEngineDelegate.swift
//  Hookies
//
//  Created by JinYing on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

protocol GameEngineDelegate: AnyObject {
    func didStartCountdown()
    func didPlayerHook(hook: HookDelegateModel)
}
