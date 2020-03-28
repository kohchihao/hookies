//
//  GameObjectMovement.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol GameObjectMovementSystemProtocol {
    func add(sprite: SpriteComponent)
    func remove(sprite: SpriteComponent)
    func add(rotate: RotateComponent)
    func remove(rotate: RotateComponent)
    func add(translate: NonPhysicsTranslateComponent)
    func remove(translate: NonPhysicsTranslateComponent)
    func add(bounce: BounceComponent)
    func remove(bounce: BounceComponent)
    func update(time: TimeInterval)
}

class GameObjectMovementSystem: System {
    var spriteComponents: [SpriteComponent] = []
    var rotateComponents: [RotateComponent] = []
    var translateComponents: [NonPhysicsTranslateComponent] = []
    var bounceComponents: [BounceComponent] = []

    init(
        sprites: [SpriteComponent],
        rotates: [RotateComponent],
        translates: [NonPhysicsTranslateComponent],
        bounces: [BounceComponent]
    ) {
        self.spriteComponents.append(contentsOf: sprites)
        self.rotateComponents.append(contentsOf: rotates)
        self.translateComponents.append(contentsOf: translates)
        self.bounceComponents.append(contentsOf: bounces)
    }

    convenience init() {
        self.init(sprites: [], rotates: [], translates: [], bounces: [])
    }


}
