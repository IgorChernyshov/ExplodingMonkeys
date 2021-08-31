//
//  GameViewController.swift
//  ExplodingMonkeys
//
//  Created by Igor Chernyshov on 31.08.2021.
//

import UIKit
import SpriteKit
import GameplayKit

final class GameViewController: UIViewController {

	// MARK: - Outlets
	@IBOutlet var angleSlider: UISlider!
	@IBOutlet var angleLabel: UILabel!
	@IBOutlet var velocitySlider: UISlider!
	@IBOutlet var velocityLabel: UILabel!
	@IBOutlet var launchButton: UIButton!
	@IBOutlet var playerLabel: UILabel!

	// MARK: - Properties
	var currentGame: GameScene!

	// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

		angleSlider.value = 45
		angleChanged(angleSlider!)
		velocitySlider.value = 125
		velocityChanged(velocitySlider!)

        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)

				// Save scene in a property
				currentGame = scene as? GameScene
				currentGame.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

	// MARK: - View Controller Settings
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

	// MARK: - UI Actions
	@IBAction func angleChanged(_ sender: Any) {
		angleLabel.text = "Angle: \(Int(angleSlider.value))°"
	}

	@IBAction func velocityChanged(_ sender: Any) {
		velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
	}

	@IBAction func launchDidTap(_ sender: Any) {
		angleSlider.isHidden = true
		angleLabel.isHidden = true

		velocitySlider.isHidden = true
		velocityLabel.isHidden = true

		launchButton.isHidden = true

		currentGame.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
	}

	// MARK: - Other Game Logic
	func activatePlayer(number: Int) {
		if number == 1 {
			playerLabel.text = "<<< PLAYER ONE"
		} else {
			playerLabel.text = "PLAYER TWO >>>"
		}

		angleSlider.isHidden = false
		angleLabel.isHidden = false

		velocitySlider.isHidden = false
		velocityLabel.isHidden = false

		launchButton.isHidden = false
	}
}
