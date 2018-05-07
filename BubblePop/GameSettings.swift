//
//  GameSettings.swift
//  BubblePop
//
//  Created by Audwin on 7/5/18.
//  Copyright © 2018 Audwin. All rights reserved.
//

import Foundation

struct GameSettings : Codable {
    var gameTime: Int = 60
    var maxBubbles: Int = 15
    
//    mutating func setMaxBubbles(to limit: Int) {
//        self.maxBubbles = limit
//    }
//    
//    mutating func setGameTime(to time: Int) {
//        self.gameTime = time
//    }
}
