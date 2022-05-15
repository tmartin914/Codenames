//
//  PlayerGame.swift
//  Codenames
//
//  Created by Tyler Martin on 6/12/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import Foundation

/// Class for current player's game
class PlayerGame {
    /// Expected input date format
    let dateFormat = "MM-dd-yyyy hh:mm:ss"
    
    /// Date Formatter
    let dateFormatter = DateFormatter()
    
    /// Game ID as string
    var gameID: String
    
    /// Player Info as string
    var playerString: String
    
    /// Name of player whose turn it is
    var turn: String
    
    /// Date time
    var timestamp: Date
    
    /// Flag indicating the game started
    var started: Bool
    
    /// Flag indicating the game ended
    var completed: Bool
    
    /// User ID of player
    var userID: String
    
    /// List of players in game
    var players = [Player]()
    
    /// Current user's team
    var team1 = [Player]()
    
    /// Opponent's team
    var team2 = [Player]()
    
    /// Parameterized Initializer
    init?(userID: String, gameID: String, playerString: String, turn: String, timestamp: String, started: String, completed: String) {
        self.userID = userID
        self.gameID = gameID
        self.playerString = playerString
        self.turn = turn
        
        dateFormatter.dateFormat = dateFormat
        guard let timestampDate = dateFormatter.date(from: timestamp) else {
            print ("Unable to convert timestamp \(timestamp) to date of format \(dateFormat)")
            return nil
        }
        self.timestamp = timestampDate
        
        if started == "true" {
            self.started = true
        } else {
            self.started = false
        }
        
        if completed == "true" {
            self.completed = true
        } else {
            self.completed = false
        }
        
        updatePlayers()
    }
    
    /// Gets the current game's data as a dictionary
    func getGameData() -> NSMutableDictionary {
        let gameData: NSMutableDictionary = [:]
        
        gameData["playerString"] = playerString
        gameData["turn"] = turn
        gameData["timestamp"] = dateFormatter.string(from: timestamp)
        gameData["started"] = started.description
        gameData["completed"] = completed.description
        
        return gameData
    }
    
    /// Updates the player string
    func updatePlayerString(playerString: String) {
        self.playerString = playerString
        updatePlayers()
    }
    
    /// Updates a player game
    func update(playerString: String, turn: String, timestamp: String, started: String, completed: String)
    {
        self.playerString = playerString
        self.turn = turn
        
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        self.timestamp = dateFormatter.date(from: timestamp)!
        
        if started == "true" {
            self.started = true
        } else {
            self.started = false
        }
        
        if completed == "true" {
            self.completed = true
        } else {
            self.completed = false
        }
        
        updatePlayers()
    }
    
    func updatePlayers() {
        do {
            try updatePlayersHelper()
        } catch PlayerGameError.InvalidPlayerString {
            print ("Could not update players")
        } catch {
            print ("Unexpected error: \(error)")
        }
    }
    
    /// Updates the players in the game
    func updatePlayersHelper() throws {
        players = []
        team1 = []
        team2 = []
        
        if playerString != "" {
            for string in playerString.components(separatedBy: ";") {
                let attributeStrings = string.components(separatedBy: ",")
                if attributeStrings.count != 2 {
                    print ("Invalid player string: \(playerString)")
                    throw PlayerGameError.InvalidPlayerString
                }
                players.append(Player(name: attributeStrings[0], team: attributeStrings[1]))
            }
            
            let usersTeam = players.filter { $0.name == userID }.first!.team
            for player in players {
                if player.team == usersTeam {
                    team1.append(player)
                } else {
                    team2.append(player)
                }
            }
        }
    }
    
    /// Gets the teammate of the current user
    func getTeammate() -> String {
        return team1.filter { $0.name != userID }.first!.name
    }
}

/// Enum for a player game error
enum PlayerGameError: Error {
    case InvalidPlayerString
}
