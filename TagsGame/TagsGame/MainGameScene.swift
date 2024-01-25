//
//  MainGameScene.swift
//  TagsGame
//
//  Created by Vitaliy Halai on 23.01.24.
//

import SpriteKit
import GameplayKit
import AVFoundation


protocol WinScreenDelegate: AnyObject {
    func presentInitialGameScene()
}

//MARK: - MainGameScene
final class MainGameScene: SKScene, WinScreenDelegate {
    
    //MARK: UI Elements
    private let timerLabel = SKLabelNode(fontNamed: "Helvetica")
    private let background = SKSpriteNode(imageNamed: "GameBackGround")
    private let infoBar = SKSpriteNode(imageNamed: "InfoBar")
    private let gameField = SKSpriteNode(imageNamed: "Gamefield")
    private let movesLabel = SKLabelNode(fontNamed: "Helvetica")
    private lazy var settingsButton = UIBuilder.createButton(withImgName: "Settings")
    private lazy var pausePlayButton = UIBuilder.createButton(withImgName: "Pause")
    private lazy var backButton = UIBuilder.createButton(withImgName: "Back")
    private lazy var restartButton = UIBuilder.createButton(withImgName: "Restart")
    
    //MARK: Private properties
    var audioPlayer: AVAudioPlayer?
    var feedbackGenerator: UINotificationFeedbackGenerator?
    
    private var elapsedTime: TimeInterval = 0.0
    private var isTimerRunning = true
    private var numberOfMoves: Int = -1 {
        didSet {
            movesLabel.text = "Moves: \(numberOfMoves)"
        }
    }
    
    
    
    
    //MARK: Tiles test
    let gridSize = 4
    let tileSize: CGFloat = 220
    
    var tiles: [SKSpriteNode] = []
    
    var shouldPerformActionAfterWin = true
    var isGamePaused = false
    var vibrationEffectIsOn = true
    var soundEffectIsOn = true
    
    //MARK: Override funcs
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupUI()
        setupGame()
        
        // Initialize feedback generator
        feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator?.prepare()
        
        if let soundURL = Bundle.main.url(forResource: "moveSound", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error initializing audio player: \(error.localizedDescription)")
            }
        }
        
        print(vibrationEffectIsOn, soundEffectIsOn)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            
            guard shouldPerformActionAfterWin else { return }
            
            if settingsButton.contains(location) {
                print("Settings tapped")
                presentSettingsScreen()
            }
            
            if pausePlayButton.contains(location) {
                switchButtonImage()
                isGamePaused.toggle()
                
                if isTimerRunning {
                    stopTimer()
                } else {
                    startTimer()
                }
                
                isTimerRunning.toggle()
            }
            
            guard !isGamePaused else { return }
            
            if backButton.contains(location) {
                presentInitialGameScene()
            }
            
            if restartButton.contains(location) {
                isTimerRunning = true
                elapsedTime = 0
                numberOfMoves = 0
                startTimer()
                pausePlayButton.texture = SKTexture(imageNamed: "Pause")
            }
            
            guard gameField.contains(location) else { return }
            
            if let touchedNode = nodes(at: location).first as? SKSpriteNode,
               let tileIndex = tiles.firstIndex(of: touchedNode) {
                moveTile(at: tileIndex)
            }
            
            
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        //This check needed to exclude unlimit execution of this code after win
        if  shouldPerformActionAfterWin,
            isWin() {
            
            shouldPerformActionAfterWin.toggle()
            print("You win!")
            stopTimer()
            presentWinScreen()
        }
    }
    
    func presentInitialGameScene() {
        let initialGameScene = InitialGameScene(size: self.size)
        initialGameScene.scaleMode = .aspectFill
        let transition = SKTransition.crossFade(withDuration: 1.0)
        self.view?.presentScene(initialGameScene, transition: transition)
    }
    
    
    private func presentWinScreen() {
        
        guard self.view?.window?.rootViewController != nil else {
            return
        }
        let winScreen = WinScene(size: self.size, numberOfMoves: numberOfMoves, elapsedTime: elapsedTime)
        self.view?.presentScene(winScreen, transition: .crossFade(withDuration: 1.0))
    }
    
    func presentSettingsScreen() {
        let screenSize = self.frame.size
        let settingsScreen = SettingsScreen(size: screenSize)
        settingsScreen.zPosition = 6
        settingsScreen.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        addChild(settingsScreen)
    }
    
    //MARK: Private funcs
    private func switchButtonImage() {
        if pausePlayButton.texture?.description.contains("Pause") ?? false {
            pausePlayButton.texture = SKTexture(imageNamed: "Play")
        } else {
            pausePlayButton.texture = SKTexture(imageNamed: "Pause")
        }
    }
}

//MARK: - 15 puzzle game tiles logic
extension MainGameScene {
    func setupGame() {
        let tileSize = CGSize(width: tileSize, height: tileSize)
        
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let number = row * gridSize + col + 1
                let tile = createTile(number: number, size: tileSize)
                tile.position = CGPoint(x: CGFloat(col) * tileSize.width, y: CGFloat(row) * tileSize.height)
                addChild(tile)
                tiles.append(tile)
            }
        }
        
        
        //        tiles.shuffle()
        moveTile(at: 14)
        updateTilePositions()
    }
    
    func createTile(number: Int, size: CGSize) -> SKSpriteNode {
        var tile = SKSpriteNode()
        if number != 16 {
            let imageName = "Number \(number)"
            tile = SKSpriteNode(imageNamed: imageName)
        } else {
            tile.color = .clear
        }
        
        tile.size = size
        tile.name = "tile\(number)"
        tile.zPosition = 4
        return tile
    }
    
    func updateTilePositions() {
        for (index, tile) in tiles.enumerated() {
            let row = index / 4
            let col = index % 4
            tile.position = CGPoint(x: CGFloat(col) * tile.size.width + gameField.frame.minX + 300, y: CGFloat(row) * tile.size.height + gameField.frame.minY + 200)
        }
    }
    
    func moveTile(at index: Int) {
        let emptyTileIndex = tiles.firstIndex { $0.name == "tile16" } ?? 0
        
        if isTileMovable(from: index, to: emptyTileIndex) {
            if soundEffectIsOn {
                // Play sound on every move
                playMoveSound()
            }
            
            if vibrationEffectIsOn {
                // Provide haptic feedback
                provideVibrationEffect()
            }
            
            
            tiles.swapAt(index, emptyTileIndex)
            updateTilePositions()
            numberOfMoves += 1
        }
        
        func provideVibrationEffect() {
            feedbackGenerator?.notificationOccurred(.success)
        }
        
        func playMoveSound() {
            audioPlayer?.play()
        }
    }
    
    
    
    func isTileMovable(from index1: Int, to index2: Int) -> Bool {
        let row1 = index1 / 4
        let col1 = index1 % 4
        let row2 = index2 / 4
        let col2 = index2 % 4
        
        return (row1 == row2 && abs(col1 - col2) == 1) || (col1 == col2 && abs(row1 - row2) == 1)
    }
    
    func isWin() -> Bool {
        for (index, tile) in tiles.enumerated() {
            let number = index + 1
            if tile.name != "tile\(number)" {
                return false
            }
        }
        return true
    }
    
}

//MARK: - StopWatch funcs
private extension MainGameScene {
    func startTimer() {
        let updateAction = SKAction.run { [weak self] in
            self?.updateTimerLabel()
        }
        let waitAction = SKAction.wait(forDuration: 0.2)
        let sequenceAction = SKAction.sequence([updateAction, waitAction])
        let timerAction = SKAction.repeatForever(sequenceAction)
        
        self.run(timerAction, withKey: "timerAction")
    }
    
    func updateTimerLabel() {
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

//MARK: - UISetup (logic excluded)
private extension MainGameScene {
    func setupUI() {
        
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
        
        settingsButton.anchorPoint = CGPoint(x: 0, y: 0)
        settingsButton.position = CGPoint(x: infoBar.frame.minX, y: infoBar.frame.maxY + 20)
        addChild(settingsButton)
        
        gameField.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameField.zPosition = 1
        gameField.size = CGSize(width: infoBar.frame.width - 20, height: (infoBar.frame.width - 20) / 1.2)
        addChild(gameField)
        
        movesLabel.fontSize = 72
        movesLabel.position = CGPoint(x: infoBar.frame.minX + 250 , y: infoBar.frame.minY + 30)
        movesLabel.text = "Moves: \(numberOfMoves)"
        movesLabel.name = "movesLabel"
        movesLabel.zPosition = 4
        addChild(movesLabel)
        
    }
}



enum UIBuilder {
    static func createButton(withImgName name: String) -> SKSpriteNode {
        let button = SKSpriteNode(imageNamed: name)
        button.zPosition = 1
        button.name = name
        return button
    }
}


class WinScene: SKScene {
    
    lazy var menuButton = UIBuilder.createButton(withImgName: "Menu")
    lazy var restartButton = UIBuilder.createButton(withImgName: "Restart")
    
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




class SettingsScreen: SKScene {
    
    let settingsNode = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: CGSize(width: 1393, height: 2340))
    let titleLabel = SKLabelNode(fontNamed: "ArialMT")
    let soundSwitch = UISwitch()
    let vibrationSwitch = UISwitch()
    
    override func didMove(to view: SKView) {
        setupSettingsScreen()
    }
    
    func setupSettingsScreen() {
        // Settings Node
        settingsNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        settingsNode.zPosition = 10
        addChild(settingsNode)
        
        // Title Label
        titleLabel.text = "Settings"
        titleLabel.fontSize = 30
        titleLabel.fontColor = SKColor.white
        titleLabel.position = CGPoint(x: 0, y: settingsNode.size.height / 2 - 50)
        settingsNode.addChild(titleLabel)
        
        // Sound Switch
        soundSwitch.isOn = true // You can set the default value based on your preferences
        addSwitchToSettingsNode(switchNode: soundSwitch, label: "Sound", position: CGPoint(x: 0, y: 20))
        
        // Vibration Switch
        vibrationSwitch.isOn = true // You can set the default value based on your preferences
        addSwitchToSettingsNode(switchNode: vibrationSwitch, label: "Vibration", position: CGPoint(x: 0, y: -40))
    }
    
    func addSwitchToSettingsNode(switchNode: UISwitch, label: String, position: CGPoint) {
        // Create SKNode to hold label and switch
        let switchContainer = SKNode()
        
        // Label
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
        
        // Position and add to settingsNode
        switchContainer.position = position
        settingsNode.addChild(switchContainer)
    }
}

