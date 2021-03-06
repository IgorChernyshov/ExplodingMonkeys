//
//  GameScene.swift
//  ExplodingMonkeys
//
//  Created by Igor Chernyshov on 31.08.2021.
//

import SpriteKit
import GameplayKit

final class GameScene: SKScene {

	// MARK: - Properties
	private var buildings = [BuildingNode]()
	private var precipitation: SKEmitterNode!

	private var player1: SKSpriteNode!
	private var player2: SKSpriteNode!
	private var banana: SKSpriteNode!

	private var currentPlayer = 1

	weak var viewController: GameViewController!

	// MARK: - Lifecycle
    override func didMove(to view: SKView) {
		backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
		physicsWorld.contactDelegate = self
		createPrecipitation()
		createBuildings()
		createPlayers()
    }

	// MARK: - Buildings
	private func createBuildings() {
		var currentX: CGFloat = -15

		while currentX < 1024 {
			let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
			currentX += size.width + 2

			let building = BuildingNode(color: .red, size: size)
			building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
			building.setup()
			addChild(building)

			buildings.append(building)
		}
	}

	// MARK: - Players
	private func createPlayers() {
		player1 = SKSpriteNode(imageNamed: "player")
		player1.name = "player1"
		player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
		player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
		player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
		player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
		player1.physicsBody?.isDynamic = false

		let player1Building = buildings[1]
		player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
		addChild(player1)

		player2 = SKSpriteNode(imageNamed: "player")
		player2.name = "player2"
		player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
		player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
		player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
		player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
		player2.physicsBody?.isDynamic = false

		let player2Building = buildings[buildings.count - 2]
		player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
		addChild(player2)
	}

	// MARK: - Wind
	private func createPrecipitation() {
//		let windX = CGFloat.random(in: -5.0 ... 5.0)
		let windX: CGFloat = 5.0
		let windY = CGFloat.random(in: -10.8 ... -8.8)
		let windVector = CGVector(dx: windX, dy: windY)
		physicsWorld.gravity = windVector

		precipitation = SKEmitterNode(fileNamed: "precipitation")!
		precipitation.position = CGPoint(x: 512, y: 812)
		precipitation.advanceSimulationTime(5)
		precipitation.xAcceleration = windX * 50
		precipitation.yAcceleration = windY * 10
		precipitation.particleColor = Bool.random() ? #colorLiteral(red: 0.4513868093, green: 0.9930960536, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		addChild(precipitation)
		precipitation.zPosition = 0
	}

	// MARK: - Game Logic
	func launch(angle: Int, velocity: Int) {
		let speed = Double(velocity) / 10.0
		let radians = convertToRadians(degrees: angle)

		if banana != nil {
			banana.removeFromParent()
			banana = nil
		}

		banana = SKSpriteNode(imageNamed: "banana")
		banana.name = "banana"
		banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
		banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
		banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
		banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
		banana.physicsBody?.usesPreciseCollisionDetection = true
		addChild(banana)

		if currentPlayer == 1 {
			banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
			banana.physicsBody?.angularVelocity = -20

			let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
			let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
			let pause = SKAction.wait(forDuration: 0.15)
			let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
			player1.run(sequence)

			let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
			banana.physicsBody?.applyImpulse(impulse)
		} else {
			banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
			banana.physicsBody?.angularVelocity = 20

			let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
			let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
			let pause = SKAction.wait(forDuration: 0.15)
			let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
			player2.run(sequence)

			let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
			banana.physicsBody?.applyImpulse(impulse)
		}
	}

	private func destroy(player: SKSpriteNode) {
		if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
			explosion.position = player.position
			addChild(explosion)
		}

		player.removeFromParent()
		banana.removeFromParent()

		if viewController.isGameOver {
			return
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			let newGame = GameScene(size: self.size)
			newGame.viewController = self.viewController
			self.viewController.currentGame = newGame

			self.changePlayer()
			newGame.currentPlayer = self.currentPlayer

			let transition = SKTransition.doorway(withDuration: 1.5)
			self.view?.presentScene(newGame, transition: transition)
		}
	}

	private func changePlayer() {
		if currentPlayer == 1 {
			currentPlayer = 2
		} else {
			currentPlayer = 1
		}

		viewController.activatePlayer(number: currentPlayer)
	}

	private func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
		guard let building = building as? BuildingNode else { return }
		let buildingLocation = convert(contactPoint, to: building)
		building.hit(at: buildingLocation)

		if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
			explosion.position = contactPoint
			addChild(explosion)
		}

		banana.name = ""
		banana.removeFromParent()
		banana = nil

		changePlayer()
	}

	override func update(_ currentTime: TimeInterval) {
		guard banana != nil else { return }

		if abs(banana.position.y) > 1000 {
			banana.removeFromParent()
			banana = nil
			changePlayer()
		}
	}

	// MARK: - Helpers
	private func convertToRadians(degrees: Int) -> Double {
		Double(degrees) * Double.pi / 180
	}
}

// MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {

	func didBegin(_ contact: SKPhysicsContact) {
		let firstBody: SKPhysicsBody
		let secondBody: SKPhysicsBody

		if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
			firstBody = contact.bodyA
			secondBody = contact.bodyB
		} else {
			firstBody = contact.bodyB
			secondBody = contact.bodyA
		}

		guard let firstNode = firstBody.node else { return }
		guard let secondNode = secondBody.node else { return }

		if firstNode.name == "banana" && secondNode.name == "building" {
			bananaHit(building: secondNode, atPoint: contact.contactPoint)
		}

		if firstNode.name == "banana" && secondNode.name == "player1" {
			viewController.player2Score += 1
			destroy(player: player1)
		}

		if firstNode.name == "banana" && secondNode.name == "player2" {
			viewController.player1Score += 1
			destroy(player: player2)
		}
	}
}
