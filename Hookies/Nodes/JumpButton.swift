//
//  JumpButton.swift
//  Hookies
//
//  Created by Marcus Koh on 19/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit

/// Represents a jump button that is located in the center of the device.

class JumpButton: ButtonNode {

    // MARK: - INIT
    init(in frame: CGRect) {
        let size = CGSize(width: 100, height: 100)
        let texture = SKTexture(imageNamed: "jump_button")
        super.init(texture: texture, color: .clear, size: size)
        self.position = CGPoint(
            x: frame.midX,
            y: frame.midY)
        self.zPosition = 100
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
