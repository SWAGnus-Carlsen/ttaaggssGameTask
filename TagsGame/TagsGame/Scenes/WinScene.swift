//
//  WinScene.swift
//  TagsGame
//
//  Created by Vitaliy Halai on 25.01.24.
//

import SpriteKit

final class WinScene: SKScene {
    
    private lazy var menuButton = UIBuilder.createButton(withImgName: "Menu")
    private lazy var restartButton = UIBuilder.createButton(withImgName: "Restart")
    
    init(size: CGSize, numberOfMoves: Int, elapsedTime: TimeInterval) {
        super.init(size: size)
        
        self.backgroundColor = SKColor.black.withAlphaComponent(0.5)
        self.name = "WinScene"
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let youWinImage = SKSpriteNode(imageNamed: "YouWin")
        youWinImage.position = CGPoint(x: 0, y: 200)
        youWinImage.zPosition = 4
        youWinImage.name = "YouWin"
        youWinImage.alpha = 1
        addChild(youWinImage)
        
        let youWinBG = SKSpriteNode(imageNamed: "YouWinBG")
        youWinBG.position = CGPoint(x: 50, y: 0)
        youWinBG.zPosition = 2
        youWinBG.name = "YouWinBG"
        addChild(youWinBG)
        
        let infoFieldImage = SKSpriteNode(imageNamed: "infoFieldImage")
        infoFieldImage.position = CGPoint(x: 0, y: -200)
        infoFieldImage.zPosition = 3
        infoFieldImage.name = "infoFieldImage"
        infoFieldImage.alpha = 1
        addChild(infoFieldImage)
        
        let movesLabel = SKLabelNode(fontNamed: "Helvetica")
        movesLabel.fontSize = 72
        movesLabel.position = CGPoint(x: 0, y: -50)
        movesLabel.text = "Moves: \(numberOfMoves)"
        movesLabel.name = "movesLabel"
        movesLabel.zPosition = 1
        infoFieldImage.addChild(movesLabel)
        
        let timerLabel = SKLabelNode(fontNamed: "Helvetica")
        timerLabel.fontSize = 72
        timerLabel.position = CGPoint(x: 0, y: movesLabel.frame.minY - 60)
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        timerLabel.text = String(format: "Time: %02d:%02d", minutes, seconds)
        timerLabel.name = "timerLabel"
        timerLabel.zPosition = 1
        infoFieldImage.addChild(timerLabel)
        
        menuButton.anchorPoint = CGPoint(x: 0, y: 1)
        menuButton.position = CGPoint(x: 50, y: infoFieldImage.frame.minY - 50)
        addChild(menuButton)
        
        restartButton.anchorPoint = CGPoint(x: 1, y: 1)
        restartButton.position = CGPoint(x: -50, y: infoFieldImage.frame.minY - 50)
        addChild(restartButton)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            let location = touch.location(in: self)
            
            if menuButton.contains(location) {
                presentInitialGameScene()
            }
            
            if restartButton.contains(location) {
                transitionToMainGameScene()
            }
        }
    }
    
    private func presentInitialGameScene() {
        let initialGameScene = InitialGameScene(size: self.size)
        initialGameScene.scaleMode = .aspectFill
        let transition = SKTransition.crossFade(withDuration: 1.0)
        self.view?.presentScene(initialGameScene, transition: transition)
    }
    
    private func transitionToMainGameScene() {
        
        guard self.view?.window?.rootViewController != nil else {
            return
        }
        let mainGameScene = MainGameScene(size: self.size)
        self.view?.presentScene(mainGameScene, transition: .crossFade(withDuration: 1.0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
