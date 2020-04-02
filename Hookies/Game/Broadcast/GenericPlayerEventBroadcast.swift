//
//  GenericPlayerEventBroadcast.swift
//  Hookies
//
//  Created by JinYing on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

protocol GenericPlayerEventBroadcast {}

extension GenericPlayerEventBroadcast {
    func broadcastUpdate(gameId: String, playerId: String, player: PlayerEntity, eventType: GenericPlayerEvent) {
        guard let genericPlayerEventData = createPlayerEventData(
            from: playerId,
            and: player,
            eventType: eventType
            ) else {
                return
        }

        API.shared.gameplay.boardcastGenericPlayerEvent(playerEvent: genericPlayerEventData)
    }

    private func createPlayerEventData(
        from playerId: String,
        and player: PlayerEntity,
        eventType: GenericPlayerEvent
    ) -> GenericPlayerEventData? {
        guard let sprite = player.getSpriteComponent() else {
            return nil
        }

        let position = Vector(point: sprite.node.position)
        let velocity = Vector(vector: sprite.node.physicsBody?.velocity)

        return GenericPlayerEventData(
            playerId: playerId,
            position: position,
            velocity: velocity,
            type: eventType
        )
    }
}
