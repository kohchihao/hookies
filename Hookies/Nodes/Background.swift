//
//  Background.swift
//  Hookies
//
//  Created by Marcus Koh on 12/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

class Background: SKSpriteNode {

    // MARK: - PROPERTIES
    private var cloudsBackground = SKSpriteNode(imageNamed: "CloudsBack")
    private var cloudsForeground = SKSpriteNode(imageNamed: "CloudsFront")
    private var backgroundBack = SKSpriteNode(imageNamed: "BGBack")
    private var backgroundFront = SKSpriteNode(imageNamed: "BGFront")

    // MARK: - INIT
    init(in size: CGSize) {
        cloudsBackground.size = size
        cloudsBackground.zPosition = -30

        cloudsForeground.size = size
        cloudsForeground.zPosition = -29

        backgroundBack.size = size
        backgroundBack.zPosition = -28

        backgroundFront.size = size
        backgroundFront.zPosition = -27

        super.init(texture: nil, color: .clear, size: size)
        addChild(cloudsBackground)
        addChild(cloudsForeground)
        addChild(backgroundBack)
        addChild(backgroundFront)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(texture: SKTexture!, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }


}
