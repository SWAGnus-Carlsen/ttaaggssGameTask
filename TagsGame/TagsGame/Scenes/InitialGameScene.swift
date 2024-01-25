//
//  InitialGameScene.swift
//  TagsGame
//
//  Created by Vitaliy Halai on 23.01.24.
//

import SpriteKit
import GameplayKit
import SafariServices

final class InitialGameScene: SKScene {
    
    private let waitAction = SKAction.wait(forDuration: 4.0)
    
    //MARK: Override funcs
    override func didMove(to view: SKView) {
        initializeBootScreen()
        performTransitionToMenu()
        showMenu()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if touchedNode == childNode(withName: "PlayNowButton") ||
               touchedNode == childNode(withName: "PlayNowButtonText")  {
                
                transitionToMainGameScene()
            }
            
            if touchedNode == childNode(withName: "PrivacyButton") {
                didTapPrivacyButton()
            }
        }
    }
    
    //MARK: Private funcs
    private func transitionToMainGameScene() {
        
        guard self.view?.window?.rootViewController != nil else {
            return
        }
        let mainGameScene = MainGameScene(size: self.size)
        self.view?.presentScene(mainGameScene, transition: .crossFade(withDuration: 1.0))
    }
    
    private func didTapPrivacyButton() {
        guard let viewController = self.view?.window?.rootViewController else {
            return
        }
        let safariViewController = SFSafariViewController(url: URL(string: "https://google.com")!)
        viewController.present(safariViewController, animated: true, completion: nil)
    }
    
    private func performTransitionToMenu() {
        guard let loadingLabel = childNode(withName: "loadingLabel"),
              let fire = childNode(withName: "BootScreenFire") else { return }
        
        let removeAction = SKAction.run {
            loadingLabel.removeFromParent()
        }
        let labelSequence = SKAction.sequence([waitAction, removeAction])
        loadingLabel.run(labelSequence)
        
        let stopFireAction = SKAction.run {
            fire.removeAllActions()
        }
        
        let fireSequence = SKAction.sequence([waitAction, stopFireAction])
        
        fire.run(fireSequence)
    }
}

//MARK: - BootScreenCreation
private extension InitialGameScene {
    
    func initializeBootScreen() {
        
        let background = SKSpriteNode(imageNamed: "BootScreenBG")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
        
        let fire = SKSpriteNode(imageNamed: "BootScreenFire")
        fire.position = CGPoint(x: size.width / 2, y: size.height / 1.5)
        fire.zPosition = 2
        fire.name = "BootScreenFire"
        addChild(fire)
        
        let loadingLabel = SKLabelNode(fontNamed: "Helvetica")
        loadingLabel.text = "Loading..."
        loadingLabel.fontSize = 72
        loadingLabel.position = CGPoint(x: size.width / 2, y: size.height / 1.5 - fire.frame.height / 2)
        loadingLabel.zPosition = 2
        loadingLabel.name = "loadingLabel"
        addChild(loadingLabel)
        
        animateBootScreenFireAndLabel()
        
        let lemon = SKSpriteNode(imageNamed: "BootScreenLemon")
        lemon.position = CGPoint(x: size.width / 5, y: size.height / 3.3)
        lemon.zPosition = 1
        addChild(lemon)
        
        let cherry = SKSpriteNode(imageNamed: "BootScreenCherry")
        cherry.position = CGPoint(x: size.width / 1.3, y: size.height / 2.5)
        cherry.zPosition = 1
        addChild(cherry)
        
        let orange = SKSpriteNode(imageNamed: "BootScreenOrange")
        orange.position = CGPoint(x: size.width / 1.3, y: size.height / 7)
        orange.zPosition = 1
        addChild(orange)
        
        let purpleberry = SKSpriteNode(imageNamed: "BootScreenPurpleberry")
        purpleberry.position = CGPoint(x: size.width / 1.4, y: size.height / 1.2)
        purpleberry.zPosition = 1
        addChild(purpleberry)
        
        let bottomSpark = SKSpriteNode(imageNamed: "BootScreenSparks")
        bottomSpark.position = CGPoint(x: size.width / 3, y: size.height / 4)
        bottomSpark.zPosition = 0
        addChild(bottomSpark)
        
        let centerSpark = SKSpriteNode(imageNamed: "BootScreenSparks")
        centerSpark.position = CGPoint(x: size.width / 1.3, y: size.height / 2)
        centerSpark.zPosition = 0
        addChild(centerSpark)
        
        let topSpark = SKSpriteNode(imageNamed: "BootScreenSparks")
        topSpark.position = CGPoint(x: size.width / 2.7, y: size.height / 1.2)
        topSpark.zPosition = 0
        addChild(topSpark)
        
    }
    
    func animateBootScreenFireAndLabel() {
        let animationOffset = size.height / 5
        let moveAction = SKAction.moveBy(x: 0, y: -animationOffset, duration: 2)
        let moveBackAction = SKAction.moveBy(x: 0, y: animationOffset, duration: 2)
        let sequence = SKAction.sequence([moveAction, moveBackAction])
        let repeatAction = SKAction.repeatForever(sequence)
        
        if let fire = childNode(withName: "BootScreenFire"),
           let loadingLabel = childNode(withName: "loadingLabel") {
            fire.run(repeatAction)
            loadingLabel.run(repeatAction)
        }
    }
}

//MARK: - Menu setup
private extension InitialGameScene {
    func showMenu() {
        var menuElementsToShow = [SKNode]()
        
        let jokerHat = SKSpriteNode(imageNamed: "jokerHat")
        jokerHat.position = CGPoint(x: size.width / 2, y: size.height / 1.8)
        jokerHat.zPosition = 3
        jokerHat.name = "jokerHat"
        addChild(jokerHat)
        menuElementsToShow.append(jokerHat)
        
        let playButtonName = "PlayNowButton"
        let playButtonTexture = SKTexture(imageNamed: playButtonName )
        let playButton = SKSpriteNode(texture: playButtonTexture)
        playButton.position = CGPoint(x: size.width / 2, y: size.height / 2.85)
        playButton.zPosition = 3
        playButton.name = playButtonName
        addChild(playButton)
        menuElementsToShow.append(playButton)
        
        let buttonText = "Play now!"
        let buttonLabel = SKLabelNode(fontNamed: "Helvetica")
        buttonLabel.text = buttonText
        buttonLabel.fontSize = 72
        buttonLabel.zPosition = 4
        buttonLabel.name = "PlayNowButtonText"
        buttonLabel.position = CGPoint(x: playButton.position.x, y: playButton.position.y - 20)
        addChild(buttonLabel)
        menuElementsToShow.append(buttonLabel)
        
        let privacyButtonName = "PrivacyButton"
        let privacyButtonTexture = SKTexture(imageNamed: privacyButtonName)
        let privacyButton = SKSpriteNode(texture: privacyButtonTexture)
        privacyButton.position = CGPoint(x: size.width / 2, y: playButton.frame.minY - 80)
        privacyButton.zPosition = 3
        privacyButton.name = privacyButtonName
        addChild(privacyButton)
        menuElementsToShow.append(privacyButton)
        
        let showAction = SKAction.run {
            menuElementsToShow.forEach {
                $0.alpha = 1.0
            }
        }
        
        let sequence = SKAction.sequence([waitAction, showAction])
        
        menuElementsToShow.forEach {
            $0.alpha = 0
            $0.run(sequence)
        }
    }
}
