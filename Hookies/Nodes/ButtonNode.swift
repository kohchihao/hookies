//
//  ButtonNode.swift
//  Hookies
//
//  Created by Marcus Koh on 12/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

/// Represents a button within the game.

enum ButtonNodeState {
    case ButtonNodeStateActive, ButtonNodeStateSelected, ButtonNodeStateDisabled, ButtonNodeStateHidden
}

class ButtonNode: SKSpriteNode {

    var touchBeganHandler: () -> Void = {  }
    var touchEndHandler: () -> Void = {  }

    var initialButtonCenter: CGPoint?

    var state: ButtonNodeState = .ButtonNodeStateActive {
        didSet {
            switch state {
            case .ButtonNodeStateActive:
                self.isUserInteractionEnabled = true
                self.alpha = 1
            case .ButtonNodeStateSelected:
                self.alpha = 0.7
            case .ButtonNodeStateDisabled:
                self.isUserInteractionEnabled = false
                self.alpha = 0.2
            case .ButtonNodeStateHidden:
                self.isUserInteractionEnabled = false
                self.alpha = 0
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
    }

    // MARK: - Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .ButtonNodeStateSelected
        touchBeganHandler()
        initialButtonCenter = self.position
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .ButtonNodeStateActive
        touchEndHandler()
        guard let initialCenter = initialButtonCenter else {
            return
        }
        self.position = initialCenter
    }

    // MARK: - Init Other ways
    override init(texture: SKTexture!, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.isUserInteractionEnabled = true
    }

}
