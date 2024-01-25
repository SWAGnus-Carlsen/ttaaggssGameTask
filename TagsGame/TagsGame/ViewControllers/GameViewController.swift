//
//  GameViewController.swift
//  TagsGame
//
//  Created by Vitaliy Halai on 23.01.24.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = InitialGameScene(size: CGSize(width: 1393, height: 2340))
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }


    override var prefersStatusBarHidden: Bool {
        return true
    }
}

    



