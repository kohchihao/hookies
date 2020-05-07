//
//  CutRopeEffectSystem.swift
//  Hookies
//
//  Created by Jun Wei Koh on 7/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol CutRopeEffectSystemDelegate: AnyObject {
    /// Unhook the sprite.
    /// - Parameter player: The sprite to unhook
    func forceUnhookFor(player: SpriteComponent)
}

protocol CutRopeEffectSystemProtocol: EffectSystemProtocol,
    PlayerDependencyProtocol {}

class CutRopeEffectSystem: System, CutRopeEffectSystemProtocol {
    var players = [SpriteComponent]()
    let effectType = CutRopeEffectComponent.self

    weak var delegate: CutRopeEffectSystemDelegate?

    func apply(on powerups: [PowerupEntity]) {
        let effects = getEffectComponents(from: powerups, with: effectType)
        effects.forEach({
            apply(effect: $0)
            remove(effect: $0)
        })
    }

    private func apply(effect: CutRopeEffectComponent) {
        let owner = effect.parent.get(PowerupComponent.self)?.owner
        guard let ownerSprite = owner?.get(SpriteComponent.self) else {
            return
        }
        switch effect.strategy {
        case .allPlayers:
            applyCutRopeOnAll(effect, by: ownerSprite)
        case .nearestFrontPlayer:
            applyCutRopeToNearestFrontPlayer(effect, by: ownerSprite)
        }
    }

    private func applyCutRopeOnAll(_ effect: CutRopeEffectComponent,
                                   by sprite: SpriteComponent
    ) {
        let players = self.players.filter({
            $0 !== sprite && !$0.isProtected(from: effect)
        })

        for player in players {
            delegate?.forceUnhookFor(player: player)
        }
    }

    private func applyCutRopeToNearestFrontPlayer(
        _ effect: CutRopeEffectComponent,
        by sprite: SpriteComponent
    ) {
        guard let playerToCut = sprite.nearestSpriteInFront(from: players),
            !playerToCut.isProtected(from: effect) else {
            return
        }
        delegate?.forceUnhookFor(player: playerToCut)
    }
}
