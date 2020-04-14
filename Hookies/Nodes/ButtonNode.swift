//
//  ButtonNode.swift
//  Hookies
//
//  Created by Marcus Koh on 12/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

enum ButtonNodeState {
    case ButtonNodeStateActive, ButtonNodeStateSelected, ButtonNodeStateDisabled, ButtonNodeStateHidden
}

class ButtonNode: SKSpriteNode {

    /* Setup a dummy action closure */
    var touchBeganHandler: () -> Void = {  }
    var touchEndHandler: () -> Void = {  }

    var initialButtonCenter: CGPoint?

    /* Button state management */
    var state: ButtonNodeState = .ButtonNodeStateActive {
        didSet {
            switch state {
            case .ButtonNodeStateActive:
                /* Enable touch */
                self.isUserInteractionEnabled = true

                /* Visible */
                self.alpha = 1
            case .ButtonNodeStateSelected:
                /* Semi transparent */
                self.alpha = 0.7
            case .ButtonNodeStateDisabled:
                self.isUserInteractionEnabled = false
                self.alpha = 0.2
            case .ButtonNodeStateHidden:
                /* Disable touch */
                self.isUserInteractionEnabled = false
                /* Hide */
                self.alpha = 0
            }
        }
    }

    /* Support for NSKeyedArchiver (loading objects from SK Scene Editor */
    required init?(coder aDecoder: NSCoder) {

        /* Call parent initializer e.g. SKSpriteNode */
        super.init(coder: aDecoder)

        /* Enable touch on button node */
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
