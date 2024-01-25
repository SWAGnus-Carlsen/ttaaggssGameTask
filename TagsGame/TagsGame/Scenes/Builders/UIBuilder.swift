//
//  UIBuilder.swift
//  TagsGame
//
//  Created by Vitaliy Halai on 25.01.24.
//

import SpriteKit

enum UIBuilder {
    static func createButton(withImgName name: String) -> SKSpriteNode {
        let button = SKSpriteNode(imageNamed: name)
        button.zPosition = 1
        button.name = name
        return button
    }
}
