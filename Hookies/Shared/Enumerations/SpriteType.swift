//
//  SpriteType.swift
//  Hookies
//
//  Created by JinYing on 14/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

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
    case finishingLine

    static let players = [
        player1, player2, player3, player4,
        player5, player6, player7, player8,
        player9, player10, player11, player12,
        player13, player14, player15
    ]
}

extension SpriteType {
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

    var zPosition: CGFloat {
        switch self {
        case .player1:
            return 3
        case .player2, .player3, .player4,
        .player5, .player6, .player7, .player8,
        .player9, .player10, .player11, .player12,
        .player13, .player14, .player15:
            return 2
        case .finishingLine, .bolt:
            return 1
        default:
            return 0
        }
    }

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

    var initialIsDynamic: Bool {
        switch self {
        default:
            return false
        }
    }

    var isDynamic: Bool {
        switch self {
        case .player1, .player2, .player3, .player4,
        .player5, .player6, .player7, .player8,
        .player9, .player10, .player11, .player12,
        .player13, .player14, .player15,
        .line:
            return true
        default:
            return false
        }
    }

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

    var allowRotation: Bool {
        switch self {
        default:
            return false
        }
    }

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
        case .finishingLine:
            return 0x1 << 16
        default:
            return 0
        }
    }

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

    var contactTestBitMask: UInt32 {
        switch self {
        case .player1, .player2, .player3, .player4,
        .player5, .player6, .player7, .player8,
        .player9, .player10, .player11, .player12,
        .player13, .player14, .player15:
            return SpriteType.finishingLine.bitMask
        case .finishingLine:
            return SpriteType.player1.bitMask | SpriteType.player2.bitMask | SpriteType.player3.bitMask
                | SpriteType.player4.bitMask | SpriteType.player5.bitMask | SpriteType.player6.bitMask
                | SpriteType.player7.bitMask | SpriteType.player8.bitMask | SpriteType.player9.bitMask
                | SpriteType.player10.bitMask | SpriteType.player11.bitMask | SpriteType.player12.bitMask
                | SpriteType.player13.bitMask | SpriteType.player14.bitMask | SpriteType.player15.bitMask
        default:
            return 0
        }
    }
}
