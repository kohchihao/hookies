//
//  SpriteType.swift
//  Hookies
//
//  Created by JinYing on 14/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

/// Represent all the sprite types and their properties in the game
enum SpriteType {
    case player1
    case player2
    case player3
    case player4
    case player5
    case player6
    case player7
    case player8
    case player9
    case player10
    case player11
    case player12
    case player13
    case player14
    case player15
    case bolt
    case line
    case powerup
    case finishingLine
    case trap

    /// All the other player type that is usable
    static let otherPlayers = [
        player2, player3, player4, player5,
        player6, player7, player8, player9,
        player10, player11, player12, player13,
        player14, player15
    ]
}

extension SpriteType {
    /// Size of each sprite
    var size: CGSize {
        switch self {
        case .player1, .player2, .player3, .player4,
             .player5, .player6, .player7, .player8,
             .player9, .player10, .player11, .player12,
             .player13, .player14, .player15:
            return CGSize(width: 50, height: 50)
        default:
            return CGSize()
        }
    }

    /// The z-position for each sprite
    var zPosition: CGFloat {
        switch self {
        case .player1:
            return 3
        case .player2, .player3, .player4,
        .player5, .player6, .player7, .player8,
        .player9, .player10, .player11, .player12,
        .player13, .player14, .player15:
            return 2
        case .finishingLine, .bolt, .powerup, .trap:
            return 1
        default:
            return 0
        }
    }

    /// The amount of friction for each sprtie
    var friction: CGFloat {
        switch self {
        case .player1, .player2, .player3, .player4,
        .player5, .player6, .player7, .player8,
        .player9, .player10, .player11, .player12,
        .player13, .player14, .player15:
            return 0
        default:
            return 0.2
        }
    }

    /// The amount of linear damping for each sprite
    var linearDamping: CGFloat {
        switch self {
        case .player1, .player2, .player3, .player4,
        .player5, .player6, .player7, .player8,
        .player9, .player10, .player11, .player12,
        .player13, .player14, .player15:
            return 0
        default:
            return 0.1
        }
    }

    /// The mass for each sprite
    var mass: CGFloat {
        switch self {
        case .player1, .player2, .player3, .player4,
        .player5, .player6, .player7, .player8,
        .player9, .player10, .player11, .player12,
        .player13, .player14, .player15:
            return 1
        default:
            return 0.1
        }
    }

    /// The isDynamic property value for each sprite
    var isDynamic: Bool {
        switch self {
        case .line:
            return true
        default:
            return false
        }
    }

    /// The affectedByGravity property for each sprite
    var affectedByGravity: Bool {
        switch self {
        case .player1, .player2, .player3, .player4,
        .player5, .player6, .player7, .player8,
        .player9, .player10, .player11, .player12,
        .player13, .player14, .player15:
            return true
        default:
            return false
        }
    }

    /// The allowRotation property value for each sprite
    var allowRotation: Bool {
        switch self {
        default:
            return false
        }
    }

    /// The category bit mask for each sprite
    var bitMask: UInt32 {
        switch self {
        case .player1:
            return 0x1 << 1
        case .player2:
            return 0x1 << 2
        case .player3:
            return 0x1 << 3
        case .player4:
            return 0x1 << 4
        case .player5:
            return 0x1 << 5
        case .player6:
            return 0x1 << 6
        case .player7:
            return 0x1 << 7
        case .player8:
            return 0x1 << 8
        case .player9:
            return 0x1 << 9
        case .player10:
            return 0x1 << 10
        case .player11:
            return 0x1 << 11
        case .player12:
            return 0x1 << 12
        case .player13:
            return 0x1 << 13
        case .player14:
            return 0x1 << 14
        case .player15:
            return 0x1 << 15
        case .powerup:
            return 0x1 << 16
        case .finishingLine:
            return 0x1 << 17
        case .trap:
            return 0x1 << 18
        default:
            return 0
        }
    }

    /// The collision bit mask for each sprite
    var collisionBitMask: UInt32 {
        switch self {
        case .player1:
            return 0x1 << 1
        case .player2:
            return 0x1 << 2
        case .player3:
            return 0x1 << 3
        case .player4:
            return 0x1 << 4
        case .player5:
            return 0x1 << 5
        case .player6:
            return 0x1 << 6
        case .player7:
            return 0x1 << 7
        case .player8:
            return 0x1 << 8
        case .player9:
            return 0x1 << 9
        case .player10:
            return 0x1 << 10
        case .player11:
            return 0x1 << 11
        case .player12:
            return 0x1 << 12
        case .player13:
            return 0x1 << 13
        case .player14:
            return 0x1 << 14
        case .player15:
            return 0x1 << 15
        default:
            return 0
        }
    }

    /// The contact bit mask for each sprite
    var contactTestBitMask: UInt32 {
        switch self {
        case .player1, .player2, .player3, .player4,
        .player5, .player6, .player7, .player8,
        .player9, .player10, .player11, .player12,
        .player13, .player14, .player15:
            return SpriteType.finishingLine.bitMask |
                SpriteType.powerup.bitMask | SpriteType.trap.bitMask
        default:
            return 0
        }
    }
}
