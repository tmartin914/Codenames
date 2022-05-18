//
//  PlayerGameManager.swift
//  Codenames
//
//  Created by Tyler Martin on 6/12/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import UIKit
import Firebase

/// Class for managing player games and interacting with Firebase
@available(iOS 14.0, *)
class PlayerGameManager: NSObject {
    
    /// Firebase reference
    static let ref = Database.database().reference ()
    
    /// Player firebase reference
    static let playerRef = ref.child("Players")
    
    /// List of player games
    static var games = [PlayerGame]()
    
    /// Record player game status in the DB given player & game IDs
    static func recordPlayerGameStatus(playerID: String, gameID: String) {
        let gameData = getGame(gameID: gameID).getGameData()
        
        playerRef.child(playerID).child("Games").child(gameID).setValue(gameData, withCompletionBlock: { (error:Error?, dbRef:DatabaseReference?) in
            if let error = error {
                print("Data could not be saved: \(error).")
            }
            else {
                // Do Nothing
            }
        })
    }
    
    /// Get player game given a game ID
    static func getGame(gameID: String) -> PlayerGame {
        return games.filter { $0.gameID == gameID }.first!
    }
    
    /// Returns flag indicating if there is a player game with the given game ID
    static func isGameID(gameID: String) -> Bool {
        if games.contains(where: { $0.gameID == gameID }) {
            return true
        } else {
            return false
        }
    }
    
    /// Load all player games frm the DB
    /// As new player games get created, update the game list
    static func loadGames(userID: String, completion: @escaping(_ result:String) -> Void) {
        playerRef.child(userID).child("Games").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let resultGames = snapshot.value as? NSDictionary
            if resultGames != nil {
                for resultGame in resultGames! {
                    let gameID = resultGame.key as! String
                    
                    if isGameID(gameID: gameID) {
                        continue
                    }
                    
                    let resultValue = resultGame.value as! NSDictionary
                    let playerString = resultValue["playerString"] as? String ?? ""
                    let turn = resultValue["turn"] as? String ?? ""
                    let timestamp = resultValue["timestamp"] as? String ?? ""
                    let started = resultValue["started"] as? String ?? ""
                    let completed = resultValue["completed"] as? String ?? ""
                    
                    let newGame = PlayerGame(userID: userID, gameID: gameID, playerString: playerString, turn: turn, timestamp: timestamp, started: started, completed: completed)
                    games.append(newGame!)
                }
            }
            completion("")
        })
    }
    
    /// Record game update in DB given a game ID and game data
    static func recordGameUpdate(gameID: String, inGameData: NSMutableDictionary) {
        let gameData: NSMutableDictionary = [:]
        gameData["playerString"] = inGameData["players"] // TODO: i think this could change the order of players - do i care?
        gameData["turn"] = inGameData["turn"]
        gameData["timestamp"] = Date().string(format: "MM-dd-yyyy hh:mm:ss")
        gameData["started"] = "true"
        gameData["completed"] = inGameData["gameCompleted"]
        
        for playerID in getGame(gameID: gameID).players {
            playerRef.child(playerID.name).child("Games").child(gameID).setValue(gameData, withCompletionBlock: { (error:Error?, dbRef:DatabaseReference?) in
                if let error = error {
                    print("Data could not be saved: \(error).")
                }
                else {
                    // Do Nothing
                }
            })
        }
    }
    
    /// Update game data in DB given user & game UDs
    static func updateGame(userID: String, gameID: String, completion: @escaping(_ result:String) -> Void) {
        playerRef.child(userID).child("Games").child(gameID).observe(DataEventType.value, with: { (snapshot) in
            let resultValue = snapshot.value as? NSDictionary
            if resultValue != nil {
                let playerString = resultValue?["playerString"] as? String ?? ""
                let turn = resultValue?["turn"] as? String ?? ""
                let timestamp = resultValue?["timestamp"] as? String ?? ""
                let started = resultValue?["started"] as? String ?? ""
                let completed = resultValue?["completed"] as? String ?? ""
                
                if !isGameID(gameID: gameID) {
                    games.append(PlayerGame(userID: userID, gameID: gameID, playerString: playerString, turn: turn, timestamp: timestamp, started: started, completed: completed)!)
                }
                
                getGame(gameID: gameID).update(playerString: playerString, turn: turn, timestamp: timestamp, started: started, completed: completed)
            }
            completion("")
        })
        
        playerRef.child(userID).child("Games").child(gameID).observe(.childRemoved, with: { (snapshot) in
            if isGameID(gameID: gameID) {
                let index = games.firstIndex(where: { $0.gameID == gameID })
                games.remove(at: index!)
            }
            completion("")
        })
    }
    
    /// Get game status data
    static func getGameStatusData() -> (Int,Int,Int) {
        var notStarted = 0
        var inProgress = 0
        var completed = 0
        for game in games {
            if game.completed == true {
                completed += 1
            } else if game.started == false {
                notStarted += 1
            } else {
                inProgress += 1
            }
        }
        
        return (notStarted, inProgress, completed)
    }
    
    /// Create new player game
    static func createNewGame(userID: String, gameID: String) {
        let gameData: NSMutableDictionary = [:]
        
        gameData["playerString"] = userID + ",blue"
        gameData["turn"] = "-1"
        gameData["started"] = false
        gameData["completed"] = false
        
        let timestamp = Date().string(format: "MM-dd-yyyy hh:mm:ss")
        gameData["timestamp"] = timestamp
        
        games.append(PlayerGame(userID: userID, gameID: gameID, playerString: gameData["playerString"] as! String, turn: "-1", timestamp: timestamp, started: "false", completed: "false")!)
        
        playerRef.child(userID).child("Games").child(gameID).setValue(gameData, withCompletionBlock: { (error:Error?, dbRef:DatabaseReference?) in
            if let error = error {
                print("Data could not be saved: \(error).")
            }
            else {
                // Do Nothing
            }
        })
    }
    
    /// Update player game in DB for a new user joining the game
    static func joinGame(userID: String, gameID: String, playerString: String) {
        let gameData: NSMutableDictionary = [:]
        
        gameData["playerString"] = playerString
        gameData["turn"] = "-1"
        gameData["started"] = false
        gameData["completed"] = false
        
        let timestamp = Date().string(format: "MM-dd-yyyy hh:mm:ss")
        gameData["timestamp"] = timestamp
        
        if !isGameID(gameID: gameID) {
            games.append(PlayerGame(userID: userID, gameID: gameID, playerString: playerString, turn: "-1", timestamp: timestamp, started: "false", completed: "false")!)
        } else {
            getGame(gameID: gameID).updatePlayerString(playerString: playerString)
        }
        
        let strings = playerString.components(separatedBy: ";")
        for string in strings {
            let attributeStrings = string.components(separatedBy: ",")
            playerRef.child(attributeStrings[0]).child("Games").child(gameID).setValue(gameData, withCompletionBlock: { (error:Error?, dbRef:DatabaseReference?) in
                if let error = error {
                    print("Data could not be saved: \(error).")
                }
                else {
                    // Do Nothing
                }
            })
        }
    }
    
    /// Remove player game from DB
    static func removeGame(gameID: String, userID: String) {
        if isGameID(gameID: gameID) {
            let strings = getGame(gameID: gameID).playerString.components(separatedBy: ";")
            let index = games.firstIndex(where: { $0.gameID == gameID })
            games.remove(at: index!)
            for string in strings {
                let attributeStrings = string.components(separatedBy: ",")
                playerRef.child(attributeStrings[0]).child("Games").child(gameID).removeValue()
            }
        }
    }
    
    /// Get all games that have a given status
    static func getGameByStatus(status: GameStatus, index: Int) -> PlayerGame {
        var gamesOfType = [PlayerGame]()
        for game in games {
            switch status {
            case .notStarted:
                if game.started == false {
                    gamesOfType.append(game)
                }
            case .inProgress:
                if game.completed == false && game.started == true {
                    gamesOfType.append(game)
                }
            case .completed:
                if game.completed == true {
                    gamesOfType.append(game)
                }
            }
        }
        
        return gamesOfType[index]
    }
}

/// Date extension
extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy hh:mm:ss"
        return formatter.string(from: self)
    }
}
