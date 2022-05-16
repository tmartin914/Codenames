//
//  AvailableGame.swift
//  Codenames
//
//  Created by Tyler Martin on 6/4/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import Foundation

/// Class for an available game. Used for selecting teams
class AvailableGame {
    /// Game code (4 character string)
    var gameCode: String
    
    /// Game ID
    var gameID: String
    
    /// Player info as a string
    var playerString: String
    
    /// List of players on the blue team
    var bluePlayers = [Player]()
    
    /// List of players on the red team
    var redPlayers = [Player]()
    
    /// Parameterized Initializer
    init(gameCode: String, gameID: String, playerString: String) {
        self.gameCode = gameCode
        self.gameID = gameID
        self.playerString = playerString
        
        updatePlayers(playerString: playerString)
    }
    
    /// Returns whether a given user ID is in the game
    func isInGame(userId: String) -> Bool {
        for player in redPlayers {
            if userId == player.name {
                return true
            }
        }
        
        for player in bluePlayers {
            if userId == player.name {
                return true
            }
        }
        
        return false
    }
    
    /// Sets the initial player roles
    func setInitialRoles() {
        bluePlayers[0].role = Role.cluer
        bluePlayers[1].role = Role.guesser
        redPlayers[0].role = Role.cluer
        redPlayers[1].role = Role.guesser
        
        playerString = "\(bluePlayers[0].name),\(bluePlayers[0].team),\(bluePlayers[0].role!);\(bluePlayers[1].name),\(bluePlayers[1].team),\(bluePlayers[1].role!);\(redPlayers[0].name),\(redPlayers[0].team),\(redPlayers[0].role!);\(redPlayers[1].name),\(redPlayers[1].team),\(redPlayers[1].role!);"
    }
    
    /// Returns all the players in the game
    func getAllPlayers() -> [Player] {
        return bluePlayers + redPlayers
    }
    
    /// Update the player string given inputs
    func updatePlayerString(userID: String, team: String) {
        if playerString == "" {
            playerString = "\(userID),\(team)"
        } else {
            playerString += ";\(userID),\(team)"
        }
    }
    
    /// Update the players given the player string
    func updatePlayers(playerString: String) {
        var players = [Player]()
        
        bluePlayers = []
        redPlayers = []
        self.playerString = playerString
        
        if playerString != "" {
            for string in playerString.components(separatedBy: ";") {
                let attributeStrings = string.components(separatedBy: ",")
                players.append(Player(name: attributeStrings[0], team: attributeStrings[1]))
            }
            
            for player in players {
                if player.team == .blue {
                    bluePlayers.append(player)
                } else {
                    redPlayers.append(player)
                }
            }
        }
    }
    
    /// Returns the game data as a dictionary
    func getGameData() -> NSMutableDictionary {
        let gameData: NSMutableDictionary = [:]
    
        gameData["gameID"] = gameID
        gameData["playerString"] = playerString
        
        return gameData
    }
    
    /// Clears the players in the game
    func clearPlayers() {
        playerString = ""
        bluePlayers = []
        redPlayers = []
    }
}
