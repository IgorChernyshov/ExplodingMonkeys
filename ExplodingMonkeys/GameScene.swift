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
	weak var viewController: GameViewController!

	// MARK: - Lifecycle
    override func didMove(to view: SKView) {
		backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
		createBuildings()
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

	// MARK: - Game Logic
	func launch(angle: Int, velocity: Int) {
		// TODO: Banana throwing code here
	}
}
