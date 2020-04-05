//
//  PowerupButton.swift
//  Hookies
//
//  Created by Jun Wei Koh on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

class PowerupButton: ButtonNode {
    private(set) var powerupType: PowerupType?

    // MARK: - INIT
    init(in frame: CGRect) {
        let size = CGSize(width: 80, height: 80)
        super.init(texture: nil, color: .clear, size: size)
        self.clearPowerup()
        self.position = CGPoint(
            x: frame.minX + 90,
            y: frame.minY + 90)

        self.zPosition = 30
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setPowerup(to type: PowerupType) {
        texture = SKTexture(imageNamed: type.buttonString)
        powerupType = type
        state = .ButtonNodeStateActive
    }

    func clearPowerup() {
        texture = SKTexture(imageNamed: "empty_powerup_button")
        state = .ButtonNodeStateDisabled
    }
}
