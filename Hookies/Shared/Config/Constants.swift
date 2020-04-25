//
//  Constants.swift
//  Hookies
//
//  Created by Jun Wei Koh on 26/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics

struct Constants {
    static let prodSocketURL = URL(string: "http://128.199.164.69:3000")!
    static let devSocketURL = URL(string: "http://128.199.164.69:3000")!

    static let requestIdLength = 8
    static let lobbyIdLength = 6
    static let inviteIdLength = 6
    static let maxPlayerCount = 4

    // Time Step in seconds
    static let botTimeStep: Double = 1.0

    // Max Game Length in seconds
    static let maxGameLength: Double = 180

    static let botPrefix = "Bot"
    static let botUsernameLength = 7

    /// Hook Powerup
    // The duration in which the player to be pulled back
    static let pullPlayerDuration = 2.0
    // The speed of pull
    static let speedOfPlayerPull = CGFloat(15.0)
}
