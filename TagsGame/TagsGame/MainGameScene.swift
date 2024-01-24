//
//  MainGameScene.swift
//  TagsGame
//
//  Created by Vitaliy Halai on 23.01.24.
//

import SpriteKit
import GameplayKit

//MARK: - MainGameScene
final class MainGameScene: SKScene {
    
    //MARK: UI Elements
    private let timerLabel = SKLabelNode(fontNamed: "Helvetica")
    private let background = SKSpriteNode(imageNamed: "GameBackGround")
    private let infoBar = SKSpriteNode(imageNamed: "InfoBar")
    
    private lazy var settingsButton = createButton(withImgName: "Settings")
    private lazy var pausePlayButton = createButton(withImgName: "Pause")
    private lazy var backButton = createButton(withImgName: "Back")
    private lazy var restartButton = createButton(withImgName: "Restart")
    
    //MARK: Private properties
    private var timer: Timer?
    private var elapsedTime: TimeInterval = 0.0
    private var isTimerRunning = true
    
    //MARK: Override funcs
    override func didMove(to view: SKView) {
        
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
        
        infoBar.position = CGPoint(x: size.width / 2, y: size.height / 1.2)
        infoBar.size = CGSize(width: size.width / 1.05, height: size.height / 19)
        infoBar.zPosition = 0
        infoBar.name = "BootScreenFire"
        addChild(infoBar)
        
        timerLabel.fontSize = 72
        timerLabel.position = CGPoint(x: infoBar.frame.maxX - 200, y: infoBar.frame.minY + 30)
        timerLabel.name = "timerLabel"
        timerLabel.zPosition = 4
        addChild(timerLabel)
        startTimer()
        
        pausePlayButton.anchorPoint = CGPoint(x: 0, y: 0.5)
        pausePlayButton.position = CGPoint(x: infoBar.frame.minX, y: size.height / 7)
        addChild(pausePlayButton)
        
        
        backButton.position = CGPoint(x: infoBar.frame.midX, y: size.height / 7)
        addChild(backButton)
        
        restartButton.anchorPoint = CGPoint(x: 1, y: 0.5)
        restartButton.position = CGPoint(x: infoBar.frame.maxX, y: size.height / 7)
        addChild(restartButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            
            if pausePlayButton.contains(location) {
                switchButtonImage()
            }
            
            if backButton.contains(location) {
                let initialGameScene = InitialGameScene(size: self.size)
                initialGameScene.scaleMode = .aspectFill
                let transition = SKTransition.crossFade(withDuration: 1.0)
                self.view?.presentScene(initialGameScene, transition: transition)
            }
            
            if pausePlayButton.contains(location) {
                if isTimerRunning {
                    stopTimer()
                } else {
                    startTimer()
                }
                isTimerRunning.toggle()
            }
            
            if restartButton.contains(location) {
                isTimerRunning = true
                elapsedTime = 0
                startTimer()
                
            }
        }
        
    }
    
    private func switchButtonImage() {
        
        if pausePlayButton.texture?.description.contains("Pause") ?? false {
            pausePlayButton.texture = SKTexture(imageNamed: "Play")
        } else {
            pausePlayButton.texture = SKTexture(imageNamed: "Pause")
        }
    }
    
    private func createButton(withImgName name: String) -> SKSpriteNode {
        let button = SKSpriteNode(imageNamed: name)
        button.zPosition = 0
        button.name = name
        return button
    }
    
    
}

//MARK: - StopWatch funcs
private extension MainGameScene {
    func startTimer() {
        let updateAction = SKAction.run { [weak self] in
            self?.updateStopwatchLabel()
        }
        let waitAction = SKAction.wait(forDuration: 0.2)
        let sequenceAction = SKAction.sequence([updateAction, waitAction])
        let timerAction = SKAction.repeatForever(sequenceAction)
        
        self.run(timerAction, withKey: "timerAction")
    }
    
    func updateStopwatchLabel() {
        //This accuracy needed in case if user will spam the Pause/Play button
        elapsedTime += 0.2
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        
    }
    
    func stopTimer() {
        self.removeAction(forKey: "timerAction")
    }
    
}
