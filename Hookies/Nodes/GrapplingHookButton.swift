//
//  GrapplingHookButton.swift
//  Hookies
//
//  Created by Marcus Koh on 12/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

/// Represents a grappling hook button that is located on the bottom right of the device.

class GrapplingHookButton: ButtonNode {

    // MARK: - INIT
    init(in frame: CGRect) {
        let size = CGSize(width: 120, height: 120)
        let texture = SKTexture(imageNamed: "grappling_hook")
        super.init(texture: texture, color: .clear, size: size)
        self.position = CGPoint(
            x: frame.maxX - 90,
            y: frame.minY + 90)

        self.zPosition = 30
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
