//
//  CollectableSystem.swift
//  Hookies
//
//  Created by Jun Wei Koh on 4/5/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

protocol CollectableSystemProtocol {
    func add(collectable: CollectableComponent)
    func collect(node: SKSpriteNode, by: SpriteComponent) -> CollectableComponent?
}

protocol CollectableDelegate: AnyObject {
    func didAnimate(for node: SKSpriteNode)
    func didCollect(powerup powerupComponent: PowerupComponent)
}

class CollectableSystem: System, CollectableSystemProtocol {
    private var collectables = [CollectableComponent]()
    weak var delegate: CollectableDelegate?

    func add(collectable: CollectableComponent) {
        collectables.append(collectable)
    }

    func collect(node: SKSpriteNode, by sprite: SpriteComponent) -> CollectableComponent? {
        guard let collectable = findCollectable(with: node) else {
            return nil
        }
        return remove(collectable)
    }

    private func remove(_ collectable: CollectableComponent) -> CollectableComponent? {
        guard let index = collectables.firstIndex(where: { $0 === collectable }),
            let collectableSprite = collectable.parent.get(SpriteComponent.self) else {
            return nil
        }

        let fade = SKAction.fadeOut(withDuration: 0.5)
        collectableSprite.node.run(fade, completion: {
            collectableSprite.node.removeFromParent()
        })
        return collectables.remove(at: index)
    }

    private func findCollectable(with node: SKSpriteNode) -> CollectableComponent? {
        for collectable in collectables {
            guard let sprite = collectable.parent.get(SpriteComponent.self) else {
                continue
            }

            if sprite.node === node {
                return collectable
            }
        }
        return nil
    }

    private func findCollectable<CollectableType: CollectableComponent>(
        at point: CGPoint,
        with: CollectableType.Type
    ) -> CollectableType? {
        for collectable in collectables {
            guard let sprite = collectable.parent.get(SpriteComponent.self) else {
                continue
            }
            if sprite.node.frame.contains(point) && collectable is CollectableType {
                return collectable as? CollectableType
            }
        }
        return nil
    }
}

// MARK: - Networking
extension CollectableSystem {
    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedPowerupCollectionAction(_:)),
            name: .receviedPowerupCollectionEvent,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(broadcastUnregisterObserver(_:)),
            name: .broadcastUnregisterObserver,
            object: nil)
    }

    @objc private func receivedPowerupCollectionAction(_ notification: Notification) {
        guard let data = notification.userInfo as? [String: PowerupCollectionSystemEvent],
            let collectionEvent = data["data"] else {
                return
        }

        let positionOfCollection = CGPoint(vector: collectionEvent.powerupPos)
        guard let collectable = findCollectable(at: positionOfCollection,
                                                with: PowerupCollectableComponent.self)
            else {
                return
        }
        _ = remove(collectable)
    }

    @objc private func broadcastUnregisterObserver(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
    }
}
