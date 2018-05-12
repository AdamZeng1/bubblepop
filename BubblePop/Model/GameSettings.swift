//
//  GameSettings.swift
//  BubblePop
//
//  Created by Audwin on 7/5/18.
//  Copyright © 2018 Audwin. All rights reserved.
//

import Foundation

// Model struct for the game settings
struct GameSettings: Codable {
    // Default values
    var gameTime: Int = 60
    var maxBubbles: Int = 15
}
