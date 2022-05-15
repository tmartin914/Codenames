//
//  PlayerManager.swift
//  Codenames
//
//  Created by Tyler Martin on 5/1/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class PlayerManager: NSObject {
    static let ref = Database.database().reference()
    static let playerRef = ref.child("Players")
    static var games = [Game]()
    
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
    
    static func getGame(gameID: String) -> Game {
        return games.filter { $0.gameID == gameID }.first!
    }
    
    static func isGameID(gameID: String) -> Bool {
        if games.contains(where: { $0.gameID == gameID }) {
            return true
        } else {
            return false
        }
    }
    
    static func loadGames(playerID: String, completion: @escaping(_ result:String) -> Void) {
        playerRef.child(playerID).child("Games").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let resultGames = snapshot.value as? NSDictionary
            if resultGames != nil {
                for resultGame in resultGames! {
                    let gameID = resultGame.key as! String
                    
                    if isGameID(gameID: gameID) {
                        continue
                    }
                    
                    let resultValue = resultGame.value as! NSDictionary
                    let blueScore = resultValue["blueScore"] as? String ?? ""
                    let redScore = resultValue["redScore"] as? String ?? ""
                    let blueLeft = resultValue["blueLeft"] as? String ?? ""
                    let redLeft = resultValue["redLeft"] as? String ?? ""
                    let turn = resultValue["turn"] as? String ?? ""
                    let firstTeam = resultValue["firstTeam"] as? String ?? ""
                    let turnOrder = resultValue["turnOrder"] as? String ?? ""
                    let firstTurnOrder = resultValue["firstTurnOrder"] as? String ?? ""
                    let matchesPlayed = resultValue["matchesPlayed"] as? String ?? ""
                    let board = resultValue["board"] as? String ?? ""
                    let clue = resultValue["clue"] as? String ?? ""
                    let numClue = resultValue["numClue"] as? String ?? ""
                    let guessesLeft = resultValue["guessesLeft"] as? String ?? ""
                    let gameCompleted = resultValue["gameCompleted"] as? String ?? ""
                    let players = resultValue["players"] as? String ?? ""
                    
                    let newGame = Game(gameID: gameID)
                    newGame.update(board: board, blueScore: blueScore, redScore: redScore, blueLeft: blueLeft, redLeft: redLeft, turn: turn, firstTeam: firstTeam, turnOrder: turnOrder, firstTurnOrder: firstTurnOrder, matchesPlayed: matchesPlayed, clue: clue, numClue: numClue, guessesLeft: guessesLeft, gameCompleted: gameCompleted, players: players)
                    games.append(newGame)
                }
            }
            completion("")
        })
    }
    
    static func updateGame(gameID: String, completion: @escaping(_ result:String) -> Void) {
        gameRef.child(gameID).observe(DataEventType.value, with: { (snapshot) in
            let resultValue = snapshot.value as? NSDictionary
            if resultValue != nil {
                let blueScore = resultValue?["blueScore"] as? String ?? ""
                let redScore = resultValue?["redScore"] as? String ?? ""
                let blueLeft = resultValue?["blueLeft"] as? String ?? ""
                let redLeft = resultValue?["redLeft"] as? String ?? ""
                let turn = resultValue?["turn"] as? String ?? ""
                let firstTeam = resultValue?["firstTeam"] as? String ?? ""
                let turnOrder = resultValue?["turnOrder"] as? String ?? ""
                let firstTurnOrder = resultValue?["firstTurnOrder"] as? String ?? ""
                let matchesPlayed = resultValue?["matchesPlayed"] as? String ?? ""
                let board = resultValue?["board"] as? String ?? ""
                let clue = resultValue?["clue"] as? String ?? ""
                let numClue = resultValue?["numClue"] as? String ?? ""
                let guessesLeft = resultValue?["guessesLeft"] as? String ?? ""
                let gameCompleted = resultValue?["gameCompleted"] as? String ?? ""
                let players = resultValue?["players"] as? String ?? ""
                
                if !isGameID(gameID: gameID) {
                    games.append(Game(gameID: gameID))
                }
                
                getGame(gameID: gameID).update(board: board, blueScore: blueScore, redScore: redScore, blueLeft: blueLeft, redLeft: redLeft, turn: turn, firstTeam: firstTeam, turnOrder: turnOrder, firstTurnOrder: firstTurnOrder, matchesPlayed: matchesPlayed, clue: clue, numClue: numClue, guessesLeft: guessesLeft, gameCompleted: gameCompleted, players: players)
            }
            completion("")
        })
    
    
    
    
    
    /*static var redPlayers = [Player]()
    //static var bluePlayers = [Player]()
    //static var gameStarted = false
    
    /*static func updatePlayerRoles() {
        
    }*/
    
    static func setInitialRoles() {
        bluePlayers[0].role = Role.cluer
        bluePlayers[1].role = Role.guesser
        redPlayers[0].role = Role.cluer
        redPlayers[1].role = Role.guesser
    }
    
    static func getTeammate(player: Player) -> Player {
        if player.team == Team.blue {
            return bluePlayers.filter { $0.name != player.name }.first!
        } else {
            return redPlayers.filter { $0.name != player.name }.first!
        }
    }
    
    static func getSameRole(player: Player) -> Player {
        if player.team == Team.blue {
            if player.name == bluePlayers[0].name {
                return redPlayers[0]
            }
            else {
                return redPlayers[1]
            }
        }
        else {
            if player.name == redPlayers[0].name {
                return bluePlayers[0]
            }
            else {
                return bluePlayers[1]
            }
        }
    }
    
    static func getAllPlayers() -> [Player] {
        return bluePlayers + redPlayers
    }
    
    static func clearPlayers() {
        redPlayers = []
        bluePlayers = []
    }
    
    static func removePlayer(player: Player) {
        if (player.team == .blue) {
            let index = bluePlayers.firstIndex(where: { $0.name == player.name })
            PlayerManager.bluePlayers.remove(at: index!)
        } else {
            let index = redPlayers.firstIndex(where: { $0.name == player.name })
            PlayerManager.redPlayers.remove(at: index!)
        }
    }
    
    static func isInGame(userId: String) -> Bool {
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
    
    static func fillPlayers(uid: String, completion: @escaping(_ result:String) -> Void) {
        clearPlayers()
        
        playerRef.queryOrdered(byChild: "uid").observe(.childAdded, with: {
            snapshot in
            let resultValue = snapshot.value as? NSDictionary
            if resultValue != nil {
                let player = Player(name: resultValue?["name"] as? String ?? "", team: resultValue?["team"] as? String ?? "")
                if player.team == Team.red {
                    PlayerManager.redPlayers.append(player)
                }
                else {
                    PlayerManager.bluePlayers.append(player)
                }
            }
            completion("")
        })
        
        playerRef.queryOrdered(byChild: "uid").observe(.childChanged, with: {
            snapshot in
            let resultValue = snapshot.value as? NSDictionary
            if resultValue != nil {
                let player = Player(name: resultValue?["name"] as? String ?? "", team: resultValue?["team"] as? String ?? "")
                if player.team == Team.red {
                    PlayerManager.redPlayers.append(player)
                }
                else {
                    PlayerManager.bluePlayers.append(player)
                }
            }
            completion("")
        })
        
        playerRef.queryOrdered(byChild: "uid").observe(.childRemoved, with: {
            snapshot in
            let resultValue = snapshot.value as? NSDictionary
            if resultValue != nil {
                let player = Player(name: resultValue?["name"] as? String ?? "", team: resultValue?["team"] as? String ?? "")
                removePlayer(player: player)
            }
            completion("")
        })
    }*/
}

