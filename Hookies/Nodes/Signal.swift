//
//  Signal.swift
//  Hookies
//
//  Created by JinYing on 4/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

class Signal: SKSpriteNode {
    // MARK: - Init

    init(in frame: CGRect) {
        let size = CGSize(width: 80, height: 80)
        let texture = SKTexture(imageNamed: "signal")
        super.init(texture: texture, color: .clear, size: size)
        position = CGPoint(x: frame.midX, y: frame.midY)
        zPosition = 200
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
