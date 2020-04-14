//
//  GrapplingHookButton.swift
//  Hookies
//
//  Created by Marcus Koh on 12/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

class GrapplingHookButton: ButtonNode {

    var touchUpHandler: () -> Void = {  }
    var touchDownHandler: () -> Void = {  }

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

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let initialCenter = initialButtonCenter else {
            return
        }

        guard let parent = self.parent else {
            return
        }

        for touch in touches {
            let touchPoint: CGPoint = touch.location(in: parent)
            if touchPoint.y > initialCenter.y { // shorten
                self.touchUpHandler()
            } else { // lengthen
                self.touchDownHandler()
            }

            let touchPointVector = Vector(point: touchPoint)
            let currentPositionVector = Vector(point: initialCenter)
            if touchPointVector.distance(to: currentPositionVector) <= 50 {
                self.position = CGPoint(x: self.position.x, y: touchPoint.y)
            }
        }
    }
}
