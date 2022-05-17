//
//  Player.swift
//  Codenames
//
//  Created by Tyler Martin on 5/1/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import Foundation

/// Class that defines a player in a game
class Player {
    
    /// name of player
    var name: String
    
    /// Player's team
    var team: Team
    
    /// Player's current role in game
    var role: Role?
    
    /// Parameterized Initializer
    init(name: String, team: Team, role: Role) {
        self.name = name
        self.team = team
        self.role = role
    }
    
    /// Initializer for prior to game start
    init(name: String, team: String) {
        self.name = name
        self.team = (team == "blue" || team == "Blue") ? Team.blue : Team.red
    }
    
    /// Initializer with all string parameters
    init(name: String, team: String, role: String) {
        self.name = name
        self.team = (team == "blue" || team == "Blue") ? Team.blue : Team.red
        self.role = (role == "cluer" || role == "Cluer") ? Role.cluer : Role.guesser
    }
}
