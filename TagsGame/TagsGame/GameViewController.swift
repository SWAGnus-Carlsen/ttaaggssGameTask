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
        let scene = MainGameScene(size: CGSize(width: 1393, height: 2340))
        let skView = self.view as! SKView
//        skView.showsFPS = true
//        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        //scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }


    override var prefersStatusBarHidden: Bool {
        return true
    }
}


class GameScene: SKScene {

    var tiles: [SKSpriteNode] = []
    var shouldPerformActionAfterWin = true
    
    override func didMove(to view: SKView) {
        setupGame()
    }

    func setupGame() {
        let tileSize = CGSize(width: 200, height: 200)
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

        return tile
    }

    func updateTilePositions() {
        for (index, tile) in tiles.enumerated() {
            let row = index / 4
            let col = index % 4
            tile.position = CGPoint(x: CGFloat(col) * tile.size.width + 300, y: CGFloat(row) * tile.size.height + 300)
        }
    }

    // Add touches handling to move the tiles
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let touchedNode = nodes(at: location).first as? SKSpriteNode,
           let tileIndex = tiles.firstIndex(of: touchedNode) {
                moveTile(at: tileIndex)
        }
    }

    func moveTile(at index: Int) {
        let emptyTileIndex = tiles.firstIndex { $0.name == "tile16" } ?? 0

        if isTileMovable(from: index, to: emptyTileIndex) {
            tiles.swapAt(index, emptyTileIndex)
            updateTilePositions()
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
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        //This check needed to exclude unlimit execution of this code after win
        if  shouldPerformActionAfterWin,
            isWin() {
            shouldPerformActionAfterWin.toggle()
            print("You win!")
           
        }
    }
    
    
    }
    



