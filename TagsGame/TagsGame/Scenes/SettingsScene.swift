//
//  SettingsScene.swift
//  TagsGame
//
//  Created by Vitaliy Halai on 25.01.24.
//

import SpriteKit

final class SettingsScene: SKScene {
    
    private let settingsNode = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: CGSize(width: 1393, height: 2340))
    private let titleLabel = SKLabelNode(fontNamed: "ArialMT")
    private let soundSwitch = UISwitch()
    private let vibrationSwitch = UISwitch()
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupSettingsScreen()
    }
    
    private func setupSettingsScreen() {
        settingsNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        settingsNode.zPosition = 10
        addChild(settingsNode)
        
     
        titleLabel.text = "Settings"
        titleLabel.fontSize = 30
        titleLabel.fontColor = SKColor.white
        titleLabel.position = CGPoint(x: 0, y: settingsNode.size.height / 2 - 50)
        settingsNode.addChild(titleLabel)
        
      
        soundSwitch.isOn = true
        addSwitchToSettingsNode(switchNode: soundSwitch, label: "Sound", position: CGPoint(x: 0, y: 20))
        
        
        vibrationSwitch.isOn = true
        addSwitchToSettingsNode(switchNode: vibrationSwitch, label: "Vibration", position: CGPoint(x: 0, y: -40))
    }
    
    private func addSwitchToSettingsNode(switchNode: UISwitch, label: String, position: CGPoint) {
        
        let switchContainer = SKNode()
        
        let labelNode = SKLabelNode(fontNamed: "ArialMT")
        labelNode.text = label
        labelNode.fontSize = 20
        labelNode.fontColor = SKColor.white
        labelNode.position = CGPoint(x: -80, y: 0)
        switchContainer.addChild(labelNode)
        
        //        // UISwitch
        //        let switchSprite = SKSpriteNode(color: .clear, size: CGSize(width: 50, height: 30))
        //        let switchTexture = SKView().texture(from: switchNode)
        //        switchSprite.texture = switchTexture
        //        switchSprite.position = CGPoint(x: 30, y: 0)
        //        switchContainer.addChild(switchSprite)
        
        
        switchContainer.position = position
        settingsNode.addChild(switchContainer)
    }
}
