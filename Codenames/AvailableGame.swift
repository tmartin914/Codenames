//
//  AvailableGame.swift
//  Codenames
//
//  Created by Tyler Martin on 6/4/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import Foundation

class AvailableGame {
    var gameCode: String
    var gameID: String
    var playerString: String
    var bluePlayers = [Player]()
    var redPlayers = [Player]()
    
    init(gameCode: String, gameID: String, playerString: String) {
        self.gameCode = gameCode
        self.gameID = gameID
        self.playerString = playerString
    }
    
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
    
    func setInitialRoles() {
        bluePlayers[0].role = Role.cluer
        bluePlayers[1].role = Role.guesser
        redPlayers[0].role = Role.cluer
        redPlayers[1].role = Role.guesser
        
        playerString = "\(bluePlayers[0].name),\(bluePlayers[0].team),\(bluePlayers[0].role!);\(bluePlayers[1].name),\(bluePlayers[1].team),\(bluePlayers[1].role!);\(redPlayers[0].name),\(redPlayers[0].team),\(redPlayers[0].role!);\(redPlayers[1].name),\(redPlayers[1].team),\(redPlayers[1].role!);"
    }
    
    func getAllPlayers() -> [Player] {
        return bluePlayers + redPlayers
    }
    
    func updatePlayerString(userID: String, team: String) {
        if playerString == "" {
            playerString = "\(userID),\(team)"
        } else {
            playerString += ";\(userID),\(team)"
        }
    }
    
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
    
    func getGameData() -> NSMutableDictionary {
        let gameData: NSMutableDictionary = [:]
    
        gameData["gameID"] = gameID
        gameData["playerString"] = playerString
        
        return gameData
    }
    
    func clearPlayers() {
        playerString = ""
        bluePlayers = []
        redPlayers = []
    }
}
