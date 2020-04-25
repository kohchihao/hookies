//
//  ShortenButton.swift
//  Hookies
//
//  Created by Marcus Koh on 20/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//
import SpriteKit

/// Represents the shorten button that is within the Game Scene.

class ShortenButton: ButtonNode {

    // MARK: - INIT
    init(in frame: CGRect) {
        let size = CGSize(width: 80, height: 80)
        let texture = SKTexture(imageNamed: "minus")
        super.init(texture: texture, color: .clear, size: size)
        self.position = CGPoint(
            x: frame.minX + 90,
            y: frame.minY + 270)

        self.zPosition = 30
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
