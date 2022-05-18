//
//  Defs.swift
//  Codenames
//
//  Created by Tyler Martin on 5/1/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import Foundation

/// Card color enum
enum Color : String {
    case red, blue, black, white
}

/// Player team enum
enum Team : String, Codable {
    case red, blue
}

/// Player role enum
enum Role : String, Codable {
    case guesser, cluer
}

/// Game status enum
enum GameStatus : String {
    case notStarted, inProgress, completed
}
