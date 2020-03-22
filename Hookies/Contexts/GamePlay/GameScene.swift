//
//  GameScene.swift
//  Hookies
//
//  Created by Tan LongBin on 7/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit
import GameplayKit
import Dispatch

class GameScene: SKScene, SKPhysicsContactDelegate {
    var gameplayId: String?
    private var gameplay: Gameplay?
    private var players = Set<Player>()
    private var playerId: String?
    private var player: Player?
    private var cannon: Cannon?
    private var finishingLine: SKSpriteNode?
    private var cam: SKCameraNode?

    private var background: Background?
    private var grapplingHookButton: GrapplingHookButton?
    private var jumpButton: JumpButton?
    private var countdownLabel: SKLabelNode?
    private var count = 5
    private var hasPlayerLaunch = false
    private var hasPlayerFinishRace = false

    private var playersAttachedAnchor: [String: SKNode] = [:]
    private var playersAnchorLineJointPin: [String: SKPhysicsJointPin] = [:]
    private var playersPositionLineJointPin: [String: SKPhysicsJointPin] = [:]

    weak var viewController: GamePlayViewController!

    private var powerLaunch = 1_000
    private var framesRenderSinceUpdated = 0

    override func didMove(to view: SKView) {
        playerId = API.shared.user.currentUser?.uid

        initialiseContactDelegate()
        initialiseBackground(with: view.frame.size)
        initialiseGrapplingHookButton()
        initialiseJumpButton()
        disableGameButtons()
        initialiseCamera()
        initialiseCountdownMessage()
        initialiseFinishingLinePhysicsBody()
        initialiseCannon()

        subscribeToGameState()
    }

    // MARK: - Update

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        updatePlayerClosestBolt()
        handlePlayerTetheringToClosestBolt()
        player?.checkIfStuck()
        resolveDeadlock()
        handleJumpButton()
        handlePlayerAfterFinishingLine()
    }

    override func didFinishUpdate() {
        guard let player = player else {
            return
        }
        centerOnNode(node: player.node)
        updateManagedPlayerState()
    }

    func setPowerLaunch(at power: Int) {
        powerLaunch = power
    }

     // MARK: - Collision Detection

    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == finishingLine || contact.bodyB.node == finishingLine {
            handlePlayerAtFinishingLine()
        }
    }

    // MARK: - Initialise contact delegate

    private func initialiseContactDelegate() {
        physicsWorld.contactDelegate = self
    }

    // MARK: - Initialise background

    private func initialiseBackground(with size: CGSize) {
        background = Background(in: size)
        guard let background = background else {
            return
        }
        addChild(background)
    }

     // MARK: - Initialise Camera

    private func initialiseCamera() {
        cam = SKCameraNode()
        self.camera = cam
        guard let cam = cam else {
            return
        }
        guard let grapplingHookButton = grapplingHookButton, let jumpButton = jumpButton else {
            return
        }
        addChild(cam)
        cam.addChild(grapplingHookButton)
        cam.addChild(jumpButton)
    }

    // MARK: - Initialise Countdown message

    private func initialiseCountdownMessage() {
        countdownLabel = SKLabelNode()
        countdownLabel?.position = CGPoint(x: 0, y: 0)
        countdownLabel?.fontColor = .black
        countdownLabel?.fontSize = size.height / 30
        countdownLabel?.zPosition = 100
        countdownLabel?.text = "Waiting for players..."

        self.cam?.addChild(countdownLabel!)
    }

     // MARK: - Initialise Grappling Hook button

    private func initialiseGrapplingHookButton() {
        guard let sceneFrame = self.scene?.frame else {
            return
        }
        grapplingHookButton = GrapplingHookButton(in: sceneFrame)
    }

    // MARK: - Initialise Finishing Line Physics Body

    private func initialiseFinishingLinePhysicsBody() {
        let type = SpriteType.finishingLine

        guard let finishingLine = self.childNode(withName: "//ending_line") as? SKSpriteNode else {
            return
        }

        finishingLine.physicsBody = SKPhysicsBody(rectangleOf: finishingLine.size)
        finishingLine.physicsBody?.isDynamic = type.isDynamic
        finishingLine.physicsBody?.allowsRotation = type.isDynamic
        finishingLine.physicsBody?.affectedByGravity = type.affectedByGravity
        finishingLine.physicsBody?.categoryBitMask = type.bitMask

        self.finishingLine = finishingLine
    }

    // MARK: - Initialise Cannon

    private func initialiseCannon() {
        guard let cannonNode = self.childNode(withName: "//cannon") as? SKSpriteNode else {
            return
        }
        self.cannon = Cannon(node: cannonNode)
    }

    // MARK: - Initialise Players

    private func initialisePlayers(_ playersId: [String]) {
        guard let gameplayId = self.gameplayId,
            let cannon = self.cannon else {
            return
        }

        for currPlayerId in playersId {
            self.initialisePlayer(at: cannon.node.position, of: currPlayerId, and: gameplayId)
        }
    }

    // MARK: - Initialise Individual Player

    private func initialisePlayer(at position: CGPoint, of playerId: String, and gameplayId: String) {
        var currPlayerCostume: CostumeType?
        API.shared.lobby.get(lobbyId: gameplayId, completion: { lobby, error in
            if error != nil {
                return
            }

            currPlayerCostume = lobby?.costumesId[playerId]

            guard let currPlayerImageName = currPlayerCostume else {
                return
            }

            let player: Player
            if playerId == self.playerId {
                let playerClosestBolt = self.getNearestBolt(from: position)

                player = Player(
                    id: playerId,
                    position: position,
                    imageName: currPlayerImageName,
                    closestBolt: playerClosestBolt
                )

                self.player = player
                self.players.insert(player)
                self.pushManagedPlayerState()

                self.handleGameStart()
            } else {
                player = Player(id: playerId, position: position, imageName: currPlayerImageName)

                self.subscribeToPlayerState(playerId)
            }

            self.addChild(player.node)
        })
    }

    // MARK: - Subscribe to game state

    private func subscribeToGameState() {
        guard let gameplayId = self.gameplayId else {
            return
        }

        API.shared.gameplay.subscribeToGameState(gameId: gameplayId, listener: gameplayStateHandler(_:_:))
    }

    // MARK: - Subscribe to player state

    private func subscribeToPlayerState(_ playerId: String) {
        guard let gameplayId = self.gameplayId else {
            return
        }

        API.shared.gameplay.subscribeToPlayerState(
            gameId: gameplayId,
            playerId: playerId,
            listener: playerStateHandler(_:_:)
        )
    }

    // MARK: - Gameplay state handler

    private func gameplayStateHandler(_ gameplay: Gameplay?, _ error: Error?) {
        if error != nil {
            return
        }

        guard let gameplay = gameplay else {
            return
        }

        print("gameplay event: \(gameplay.gameState)")

        switch gameplay.gameState {
        case .waiting:
            self.gameplay = gameplay
            self.initialisePlayers(gameplay.playersId)
        case .start:
            print("start start start")
            self.gameplay = gameplay
            self.startCountdown()
        }
    }

    // MARK: - Player state handler

    private func playerStateHandler(_ playerGameState: PlayerGameState?, _ error: Error?) {
        if error != nil {
            return
        }

        guard let playerGameState = playerGameState else {
            return
        }

        print("player state event: \(playerGameState.playerId)")

        let isOtherPlayerReady = players.contains(where: { $0.id == playerGameState.playerId })

        print("player state: \(isOtherPlayerReady)")

        if !isOtherPlayerReady {
            handleOtherPlayerIsReady(playerGameState)
        } else {
            renderPlayer(playerGameState)
        }
    }

    // MARK: - Update managed player state

    private func updateManagedPlayerState() {
        let isToUpdateFrame = framesRenderSinceUpdated >= 10

        if !hasPlayerLaunch || hasPlayerFinishRace {
            print("player launch: \(hasPlayerLaunch)")
            return
        }

        if !isToUpdateFrame {
//            print("not time to update frame: \(framesRenderSinceUpdated)")
            framesRenderSinceUpdated += 1
            return
        }

        print("time to push: \(framesRenderSinceUpdated)")
        pushManagedPlayerState()
        framesRenderSinceUpdated = 0
        print("updated frame to firestore")
    }

    // MARK: - Push managed player state

    private func pushManagedPlayerState() {
        print("push state")
        guard let gameplayId = gameplayId,
            let managedPlayer = player else {
                print("pushing: some properties are nil")
                return
        }

        let managedPlayerState = createPlayerState(from: managedPlayer)

        API.shared.gameplay.savePlayerState(gameId: gameplayId, playerState: managedPlayerState)
        print("done pushing \(managedPlayerState)")
    }

    // MARK: - Centering camera

    private func centerOnNode(node: SKNode) {
        let action = SKAction.move(to: CGPoint(x: node.position.x, y: 0), duration: 0.5)
        self.cam?.run(action)
        self.background?.run(action)
    }

    // MARK: - Launch player

    private func launchPlayer() {
        guard let player = player else {
            return
        }
        let velocity = getLaunchVelocity()
        cannon?.launch(player: player, with: velocity)
        cannon?.node.removeFromParent()
        pushManagedPlayerState()
        hasPlayerLaunch = true
    }

    // MARK: - Count down to start game

    private func startCountdown() {
        countdown(count: count)
    }

    func countdown(count: Int) {
        countdownLabel?.text = "Launching player in \(count)..."

        let counterDecrement = SKAction.sequence([SKAction.wait(forDuration: 1.0),
                                                  SKAction.run(countdownAction)])

        run(SKAction.sequence([SKAction.repeat(counterDecrement, count: count), SKAction.run(endCountdown)]))

    }

    private func countdownAction() {
        count -= 1
        countdownLabel?.text = "Launching player in \(count)..."
    }

    private func endCountdown() {
        enableGameButtons()
        countdownLabel?.removeFromParent()
        viewController.hidePowerSlider()
        launchPlayer()
    }

    // MARK: - Calculate nearest bolt

    private func getNearestBolt(from position: CGPoint) -> SKSpriteNode? {
        let allBolts = self["bolt"] // getting all the bolts within the scene.
        var closestBolt: SKSpriteNode?
        var closestDistance = Double.greatestFiniteMagnitude
        for bolt in allBolts {
            let boltPosition = bolt.position
            let distanceX = boltPosition.x - position.x
            let distanceY = boltPosition.y - position.y
            let distance = sqrt(distanceX * distanceX + distanceY * distanceY)
            closestDistance = min(Double(distance), closestDistance)
            if closestDistance == Double(distance) {
                closestBolt = bolt as? SKSpriteNode
            }
        }
        enumerateChildNodes(withName: "bolt") { node, _ in
            node.isHidden = false
        }

        return closestBolt
    }

    // MARK: - Create Player State

    private func createPlayerState(from player: Player) -> PlayerGameState {
        let position = Vector(x: Double(player.node.position.x), y: Double(player.node.position.y))

        var velocity = Vector(x: 0, y: 0)
        if let playerPhysicsBody = player.node.physicsBody {
            velocity = Vector(x: Double(playerPhysicsBody.velocity.dx), y: Double(playerPhysicsBody.velocity.dy))
        }

        var attachedBolt: Vector?
        if let playerAttachedBolt = player.attachedBolt {
            attachedBolt = Vector(x: Double(playerAttachedBolt.position.x), y: Double(playerAttachedBolt.position.y))
        }

        let playerGameState = PlayerGameState(
            playerId: player.id,
            position: position,
            velocity: velocity,
            imageName: player.imageName,
            lastUpdateTime: Date(),
            powerup: player.powerup,
            attachedPosition: attachedBolt
        )

        return playerGameState
    }

    private func getLaunchVelocity() -> CGVector {
        let dx = CGFloat(powerLaunch)
        let dy = CGFloat(powerLaunch)

        return CGVector(dx: dx, dy: dy)
    }

    // MARK: - Game Buttons

    private func disableGameButtons() {
        grapplingHookButton?.state = .ButtonNodeStateDisabled
        jumpButton?.state = .ButtonNodeStateHidden
    }

    private func enableGameButtons() {
        grapplingHookButton?.state = .ButtonNodeStateActive
    }

    private func handleGameStart() {
        guard let gameplay = gameplay else {
            return
        }

        if gameplay.gameState == .start {
            return
        }

        let isAllPlayersLoaded = gameplay.playersId.count == players.count

        if !isAllPlayersLoaded {
            return
        }

        var playersId = [String]()
        for player in players {
            playersId.append(player.id)
        }

        let gameplayStart = Gameplay(
            gameId: gameplay.gameId,
            gameState: .start,
            playersId: playersId
        )

        API.shared.gameplay.saveGameState(gameplay: gameplayStart)
    }

    private func updatePlayerClosestBolt() {
        guard let player = player else {
            return
        }

        guard let playerClosestBolt = getNearestBolt(from: player.node.position) else {
            return
        }

        player.closestBolt = playerClosestBolt
    }

    // MARK: - Player tethering to hook

    private func handlePlayerTetheringToClosestBolt() {
        grapplingHookButton?.touchBeganHandler = handleGrapplingHookBtnTouchBegan
        grapplingHookButton?.touchEndHandler = handleGrapplingHookBtnTouchEnd
    }

    private func handleGrapplingHookBtnTouchBegan() {
        guard let player = self.player else {
            return
        }

        player.tetherToClosestBolt()
        guard let playerInitialVelocity = player.node.physicsBody?.velocity else {
            return
        }
        joinBolt(to: player)
        player.node.physicsBody?.applyImpulse(playerInitialVelocity)
    }

    private func handleGrapplingHookBtnTouchEnd() {
        guard let player = self.player else {
            return
        }

        removeJointBolt(from: player)
    }

    private func joinBolt(to player: Player) {
        print("join bolt")
        guard let playerLine = player.line,
            let playerAttachedBolt = player.attachedBolt
            else {
                print("joinbolt: no player attribute")
                print("line: \(player.line)")
                print("attachedBolt: \(player.attachedBolt)")
                return
        }

        let anchor = SKNode()
        anchor.position = playerAttachedBolt.position
        anchor.physicsBody = SKPhysicsBody()
        anchor.physicsBody?.isDynamic = SpriteType.bolt.isDynamic

        self.addChild(anchor)
        self.addChild(playerLine)

        guard let anchorPhysicsBody = anchor.physicsBody,
            let linePhysicsBody = playerLine.physicsBody,
            let playerPhyscisBody = player.node.physicsBody
            else {
                print("joinbolt: no physics body")
                print("line: \(playerLine.physicsBody)")
                print("player: \(player.node.physicsBody)")
                print("anchor: \(anchor.physicsBody)")
                return
        }

        let boltToLine = SKPhysicsJointPin.joint(
            withBodyA: anchorPhysicsBody,
            bodyB: linePhysicsBody,
            anchor: anchor.position
        )
        self.physicsWorld.add(boltToLine)

        let lineToPlayer = SKPhysicsJointPin.joint(
            withBodyA: playerPhyscisBody,
            bodyB: linePhysicsBody,
            anchor: player.node.position
        )
        self.physicsWorld.add(lineToPlayer)

        self.playersAttachedAnchor[player.id] = anchor
        self.playersAnchorLineJointPin[player.id] = boltToLine
        self.playersPositionLineJointPin[player.id] = lineToPlayer

        print(self.playersAttachedAnchor)
    }

    private func removeJointBolt(from player: Player) {
        guard let playerLine = player.line,
            let playerAttachedAnchor = playersAttachedAnchor[player.id],
            let playerAnchorLineJointPin = playersAnchorLineJointPin[player.id],
            let playerPositionLineJointPin = playersPositionLineJointPin[player.id]
            else {
                print("remove bolt: no drawn property")
                print("line: \(player.line)")
                print("anchor: \(playersAttachedAnchor[player.id])")
                print("bolttoline: \(playersAnchorLineJointPin[player.id])")
                print("linetoposition: \(playersPositionLineJointPin[player.id])")
                return
        }

        player.releaseFromBolt()
        playerLine.removeFromParent()
        playerAttachedAnchor.removeFromParent()
        self.physicsWorld.remove(playerAnchorLineJointPin)
        self.physicsWorld.remove(playerPositionLineJointPin)
        self.playersAttachedAnchor.removeValue(forKey: player.id)
        self.playersAnchorLineJointPin.removeValue(forKey: player.id)
        self.playersPositionLineJointPin.removeValue(forKey: player.id)
    }

    // MARK: - Resolve deadlock

    private func initialiseJumpButton() {
        guard let sceneFrame = self.scene?.frame else {
            return
        }
        jumpButton = JumpButton(in: sceneFrame)
    }

    private func handleJumpButton() {
        jumpButton?.touchBeganHandler = handleJumpButtonTouched
        jumpButton?.touchEndHandler = handleJumpButtonTouchEnd
    }

    private func handleJumpButtonTouched() {
        player?.node.physicsBody?.applyImpulse(CGVector(dx: 500, dy: 500))
    }

    private func handleJumpButtonTouchEnd() {
        jumpButton?.state = .ButtonNodeStateHidden
    }

    private func resolveDeadlock() {
        guard grapplingHookButton?.state != .ButtonNodeStateDisabled else {
            return
        }
        guard let player = player, !player.isAttachedToBolt else {
            return
        }

        if player.isStuck {
            jumpButton?.state = .ButtonNodeStateActive
        }
    }

    // MARK: - Handle player at finishing line

    private func handlePlayerAtFinishingLine() {
        hasPlayerFinishRace = true
        disableGameButtons()
    }

    private func handlePlayerAfterFinishingLine() {
        if !hasPlayerFinishRace {
            return
        }

        player?.bringToStop()
    }

    private func handleOtherPlayerIsReady(_ playerGameState: PlayerGameState) {
        let playerPosition = CGPoint(x: playerGameState.position.x, y: playerGameState.position.y)

        let player = Player(
            id: playerGameState.playerId,
            position: playerPosition,
            imageName: playerGameState.imageName
        )

        players.insert(player)

        handleGameStart()
    }

    private func getBoltAt(position: CGPoint) -> SKSpriteNode? {
        let allBolts = self["bolt"]
        let bolt = allBolts.first(where: { $0.position == position })

        return bolt as? SKSpriteNode
    }

    private func renderPlayer(_ playerGameState: PlayerGameState) {
        print("render player")
        guard let currPlayer = players.first(where: { $0.id == playerGameState.playerId }) else {
            return
        }

        currPlayer.node.removeFromParent()
        if let currPlayerLine = currPlayer.line {
            print("removing player line & bolt")
            currPlayerLine.removeFromParent()
        }

        let newPosition = CGPoint(x: playerGameState.position.x, y: playerGameState.position.y)
        var attachedBolt: SKSpriteNode?

        if let currPlayerAttachedBolt = playerGameState.attachedPosition {
            print("new bolt")
            let attachedBoltPosition = CGPoint(x: currPlayerAttachedBolt.x, y: currPlayerAttachedBolt.y)
            attachedBolt = getBoltAt(position: attachedBoltPosition)
            print("attachedBolt: \(attachedBolt)")
        }

        print("before: \(currPlayer.node.position)")
        currPlayer.renderNewFrame(position: newPosition, attachedBolt: attachedBolt)
        addChild(currPlayer.node)
        print("after: \(currPlayer.node.position)")

        if let currPlayerLine = currPlayer.line {
            print("adding \(playerGameState.playerId) line")
            addChild(currPlayerLine)
        }
        print("render done")
    }
}
