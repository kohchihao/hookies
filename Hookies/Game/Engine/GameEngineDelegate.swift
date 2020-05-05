//
//  GameEngineDelegate.swift
//  Hookies
//
//  Created by JinYing on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

/// Delegates from the GameEngine
protocol GameEngineDelegate: AnyObject {
    /// Start the countdown for the game
    func startCountdown()

    /// To create the hook to the scene for a player
    /// - Parameter hook: Required elelments to hook
    func playerDidHook(to hook: HookDelegateModel)

    /// To remove the hook from the scene for a player
    /// - Parameter hook: Required elements to unhook
    func playerDidUnhook(from hook: HookDelegateModel)

    /// Indicates that the current player is in a deadlock
    func playerIsStuck()

    /// Indicates that the current player has finish the race
    func playerHasFinishRace()

    /// Draw a line in the scene between two player
    /// - Parameter line: the line to be drawn
    func playerHookToPlayer(with line: SKShapeNode)

    /// To add the current player to the scene
    /// - Parameter sprite: the current player's node
    func addCurrentPlayer(with sprite: SKSpriteNode)

    /// To add the other players (not on the device) to the scene
    /// - Parameter sprite: the player's sprite
    func addPlayer(with sprite: SKSpriteNode)

    /// To add a player (other than current player) that is on the current device to the scene
    /// - Parameter sprite: the player's node
    func addLocalPlayer(with sprite: SKSpriteNode)

    /// Indicates that the current player has reconnected to the game
    func currentPlayerIsReconnected()

    /// Indicates that the current player has disconnected from the game
    func currentPlayerIsDisconnected()

    /// Indicates that the game has ended
    /// - Parameter rankings: The ordering of the players that finished the race
    func gameHasFinish(rankings: [Player])

    /// To add the powerup trap to the scene
    /// - Parameter sprite: the trap's node
    func addTrap(with sprite: SKSpriteNode)

    /// To enable or disable movement buttons in the scene
    /// - Parameter isDisabled:true is enable the buttons, vice versa for false
    func movementButton(isDisabled: Bool)

    /// To remove the powerup from the current player in the scene
    /// - Parameter powerup: the powerup type to remove
    func hasPowerupStolen(powerup: PowerupType)

    /// To add stolen powerup to the current player
    /// - Parameter powerup: the powerup type to add
    func hasStolen(powerup: PowerupType)

    /// To add collected powerup to the current player
    /// - Parameter powerup: the powerup type to add
    func hasCollected(powerup: PowerupType)

    /// Will be called when the node is to added into game scene
    /// - Parameter node: The node to be added into game scene
    func hasAdded(node: SKSpriteNode)
}
