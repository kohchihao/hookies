//
//  UserConnectionSystem.swift
//  Hookies
//
//  Created by JinYing on 4/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

protocol UserConnectionSystemProtocol {

}

class UserConnectionSystem: System, UserConnectionSystemProtocol {
    func disconnect(sprite: SpriteComponent) {
        sprite.node.physicsBody?.isDynamic = false
    }

    func reconnect(sprite: SpriteComponent) {
        sprite.node.physicsBody?.isDynamic = true
    }
}
