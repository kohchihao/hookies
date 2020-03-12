//
//  ButtonNode.swift
//  Hookies
//
//  Created by Marcus Koh on 12/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

enum ButtonNodeState {
    case ButtonNodeStateActive, ButtonNodeStateSelected, ButtonNodeStateHidden
}

class ButtonNode: SKSpriteNode {

    /* Setup a dummy action closure */
    var selectedHandler: () -> Void = { print("No button action set") }

    /* Button state management */
    var state: ButtonNodeState = .ButtonNodeStateActive {
        didSet {
            switch state {
            case .ButtonNodeStateActive:
                /* Enable touch */
                self.isUserInteractionEnabled = true

                /* Visible */
                self.alpha = 1
                break
            case .ButtonNodeStateSelected:
                /* Semi transparent */
                self.alpha = 0.7
                break
            case .ButtonNodeStateHidden:
                /* Disable touch */
                self.isUserInteractionEnabled = false

                /* Hide */
                self.alpha = 0
                break
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
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedHandler()
        state = .ButtonNodeStateActive
    }

    // MARK: - Init Other ways
    override init(texture: SKTexture!, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.isUserInteractionEnabled = true
    }

}
