//
//  MainGameScene.swift
//  TagsGame
//
//  Created by Vitaliy Halai on 23.01.24.
//

import SpriteKit
import GameplayKit
import AVFoundation

//MARK: - MainGameScene
final class MainGameScene: SKScene {
    
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
    var winScreen: WinScreen?
    
    
    
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
                let initialGameScene = InitialGameScene(size: self.size)
                initialGameScene.scaleMode = .aspectFill
                let transition = SKTransition.crossFade(withDuration: 1.0)
                self.view?.presentScene(initialGameScene, transition: transition)
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
    
    func presentWinScreen() {
        let screenSize = self.frame.size
        let winScreen = WinScreen(size: screenSize)
        winScreen.zPosition = 6
        winScreen.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        addChild(winScreen)
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
        let tileSize = CGSize(width: 220, height: 220)
        let numRows = 4
        let numCols = 4
        
        for row in 0..<numRows {
            for col in 0..<numCols {
                let number = row * numCols + col + 1
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
            // Play sound on every move
            playMoveSound()
            
            // Provide haptic feedback
            provideVibrationEffect()
            
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
        button.zPosition = 0
        button.name = name
        return button
    }
}


class WinScreen: SKSpriteNode {

    var winLabel = SKLabelNode()

    init(size: CGSize) {
        super.init(texture: nil, color: SKColor.black, size: size)

        self.alpha = 0.7

        winLabel = SKLabelNode(text: "You Win!")
        winLabel.fontSize = 100
        winLabel.fontName = "Helvetica"
        winLabel.fontColor = SKColor.green
        winLabel.position = CGPoint(x: 0, y: 50)
        addChild(winLabel)
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

