//
//  GameManager.swift
//  Codenames
//
//  Created by Tyler Martin on 5/1/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import UIKit
import Firebase

class GameManager: NSObject {
    static let ref = Database.database().reference()
    static let gameRef = ref.child("Games")
    
    static var games = [Game]()
    
    static func recordGameStatus(gameID: String) {
        let gameData = getGame(gameID: gameID).getGameData()
        
        gameRef.child(gameID).setValue(gameData, withCompletionBlock: { (error:Error?, dbRef:DatabaseReference?) in
            if let error = error {
                print("Data could not be saved: \(error).")
            }
            else {
                // Do Nothing
            }
        })
        
        PlayerGameManager.recordGameUpdate(gameID: gameID, inGameData: gameData)
    }
    
    static func isGameID(gameID: String) -> Bool {
        if games.contains(where: { $0.gameID == gameID }) {
            return true
        } else {
            return false
        }
    }
    
    static func getGame(gameID: String) -> Game {
        return games.filter { $0.gameID == gameID }.first!
    }
    
    static func loadGames(completion: @escaping(_ result:String) -> Void) {
        gameRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
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
        
        /*gameRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
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
                
                game!.update(board: board, blueScore: blueScore, redScore: redScore, blueLeft: blueLeft, redLeft: redLeft, turn: turn, firstTeam: firstTeam, turnOrder: turnOrder, firstTurnOrder: firstTurnOrder, matchesPlayed: matchesPlayed, clue: clue, numClue: numClue, guessesLeft: guessesLeft, gameCompleted: gameCompleted, players: players)
            }
            completion("")
        })*/
        
        /*gameRef.observe(.childAdded, with: { snapshot in
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
                
                game!.update(board: board, blueScore: blueScore, redScore: redScore, blueLeft: blueLeft, redLeft: redLeft, turn: turn, firstTeam: firstTeam, turnOrder: turnOrder, firstTurnOrder: firstTurnOrder, matchesPlayed: matchesPlayed, clue: clue, numClue: numClue, guessesLeft: guessesLeft, gameCompleted: gameCompleted, players: players)
            }
            completion("")
        })
        
        gameRef.observe(.childChanged, with: { (snapshot) in
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
                
                game!.update(board: board, blueScore: blueScore, redScore: redScore, blueLeft: blueLeft, redLeft: redLeft, turn: turn, firstTeam: firstTeam, turnOrder: turnOrder, firstTurnOrder: firstTurnOrder, matchesPlayed: matchesPlayed, clue: clue, numClue: numClue, guessesLeft: guessesLeft, gameCompleted: gameCompleted, players: players)
            }
            completion("")
        })*/
    }
}

