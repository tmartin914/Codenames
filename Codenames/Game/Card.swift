//
//  Card.swift
//  Codenames
//
//  Created by Tyler Martin on 5/16/22.
//  Copyright © 2022 Tyler Martin. All rights reserved.
//

import Foundation

/// Struct for a game card
struct Card {
    
    /// word on card
    let word: String
    
    /// card color
    let color: Color
    
    /// Flag indicating if card was guessed in game
    var guessed: Bool
    
    /// Parameterized Initializer
    init(word: String, color: Color, guessed: Bool) {
        self.word = word
        self.color = color
        self.guessed = guessed
    }
    
    /// Initializer with all string parameters
    init(word: String, color: String, guessed: String) {
        self.word = word
        
        switch color {
        case "blue":
            self.color = Color.blue
        case "red":
            self.color = Color.red
        case "black":
            self.color = Color.black
        case "white":
            self.color = Color.white
        default:
            self.color = Color.white // Should never reach
        }
        
        self.guessed = (guessed == "true") ? true : false
    }
}
