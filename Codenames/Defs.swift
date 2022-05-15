//
//  Defs.swift
//  Codenames
//
//  Created by Tyler Martin on 5/1/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
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
        
        switch guessed {
        case "true":
            self.guessed = true
        case "false":
            self.guessed = false
        default:
            self.guessed = false // Should never reach
        }
    }
}

/// Card color enum
enum Color : String {
    case red, blue, black, white
}

/// Player team enum
enum Team : String {
    case red, blue
}

/// Player role enum
enum Role : String {
    case guesser, cluer
}

/// Game status enum
enum GameStatus : String {
    case notStarted, inProgress, completed
}
