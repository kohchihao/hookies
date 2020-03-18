//
//  SpriteType.swift
//  Hookies
//
//  Created by JinYing on 14/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

enum SpriteType {
    case player
    case bolt
    case line
    case finishingLine
}

extension SpriteType {
    var size: CGSize {
        switch self {
        case .player:
            return CGSize(width: 50, height: 50)
        default:
            return CGSize()
        }
    }

    var zPosition: CGFloat {
        switch self {
        case .player:
            return 2
        case .finishingLine:
            return 1
        default:
            return 0
        }
    }

    var friction: CGFloat {
        switch self {
        case .player:
            return 0
        default:
            return 0.2
        }
    }

    var linearDamping: CGFloat {
        switch self {
        case .player:
            return 0
        default:
            return 0.1
        }
    }

    var mass: CGFloat {
        switch self {
        case .player:
            return 1
        default:
            return 0.1
        }
    }

    var isDynamic: Bool {
        switch self {
        case .player, .line:
            return true
        default:
            return false
        }
    }

    var affectedByGravity: Bool {
        switch self {
        case .player:
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
        case .player:
            return 0x1 << 1
        case .finishingLine:
            return 0x1 << 2
        default:
            return 0
        }
    }

    var collisionBitMask: UInt32 {
        switch self {
        case .player:
            return SpriteType.finishingLine.bitMask
        case .finishingLine:
            return SpriteType.player.bitMask
        default:
            return 0
        }
    }
}
