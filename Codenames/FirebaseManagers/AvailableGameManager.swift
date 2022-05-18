//
//  AvailableGameManager.swift
//  Codenames
//
//  Created by Tyler Martin on 6/4/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import UIKit
import Firebase

/// Class for managing available games and interacting with Firebase
class AvailableGameManager: NSObject {
    
    /// Firebase reference
    static let ref = Database.database().reference()
    
    /// Available game firebase reference
    static let availableGameRef = ref.child(FirebaseConstants.AVAILABLE_GAMES_REF)
    
    /// List of available games
    static var games = [AvailableGame]()
    
    /// Record game status in DB given the game code
    static func recordGameStatus(gameCode: String) {
        //let gameData = getGame(gameCode: gameCode).getGameData()
        let encodedData = try! JSONEncoder().encode(getGame(gameCode: gameCode))
        let jsonString = String(data: encodedData,
                                encoding: .utf8)
        //let gameData = jsonString
        
        availableGameRef.child(gameCode).setValue(jsonString, withCompletionBlock: { (error:Error?, dbRef:DatabaseReference?) in
            if let error = error {
                print("Data could not be saved: \(error).")
            }
            else {
                // Do Nothing
            }
        })
    }
    
    /// Create a new game for a given user ID
    static func createNewGame(userID: String) -> (String,String) {
        //let gameData: NSMutableDictionary = [:]
        let gameCode = generateGameCode()
        let gameID = UUID().description
        
        let newGame = AvailableGame(gameCode: generateGameCode(), gameID: UUID().description)
        let encodedData = try! JSONEncoder().encode(newGame)
        let jsonString = String(data: encodedData,
                                encoding: .utf8)
        
//        gameData["gameID"] = gameID
//        gameData["playerString"] = userID + ",blue"
        
        availableGameRef.child(gameCode).setDa
        
        availableGameRef.child(gameCode).setValue(jsonString, withCompletionBlock: { (error:Error?, dbRef:DatabaseReference?) in
            if let error = error {
                print("Data could not be saved: \(error).")
            }
            else {
                // Do Nothing
            }
        })
        
        return (gameCode,gameID)
    }
    
    // TODO: modify to guarantee no match
    /// Generate a random game code
    static func generateGameCode() -> String {
        let characters = "abcdefghijklmnopqrstuvwxyz0123456789"
        let gameCode = String((0..<4).map{ _ in characters.randomElement()! })
        
        return gameCode
    }
    
    /// Return flag indicating if the given game code is a valid game code
    static func isGameCode(gameCode: String) -> Bool {
        if games.contains(where: { $0.gameCode == gameCode }) {
            return true
        } else {
            return false
        }
    }
    
    /// Get game given a game code
    static func getGame(gameCode: String) -> AvailableGame {
        return games.filter { $0.gameCode == gameCode }.first!
    }
    
    /// Get game code given a game ID
    static func getGameCode(gameID: String) -> String {
        return games.filter { $0.gameID == gameID }.first!.gameCode
    }
    
    /// Update the list of available games as new games get created in the DB
    static func watchGames(completion: @escaping(_ result:String) -> Void) {
        
        availableGameRef.queryOrdered(byChild: "uid").observe(.childAdded, with: {
            snapshot in
//            let resultValue = snapshot.value as? NSDictionary
            guard let resultValue = snapshot.value else { return }
            //if resultValue != nil {
            do {
                let game = try JSONDecoder().decode(AvailableGame.self, from: resultValue as! String)
                games.append(game)
            } catch let error {
                print(error)
            }
            completion("")
        })
//            completion("")
//        })
        
        availableGameRef.queryOrdered(byChild: "uid").observe(.childRemoved, with: {
            snapshot in
            let resultValue = snapshot.value as? NSDictionary
            if resultValue != nil {
                let gameCode = snapshot.key
                let index = games.firstIndex(where: { $0.gameCode == gameCode })
                games.remove(at: index!)
            }
            completion("")
        })
    }
    
    /// Update a game if it changes in the DB
    static func watchGame(gameCode: String, completion: @escaping(_ result:String) -> Void) {
        availableGameRef.child(gameCode).observe(DataEventType.value, with: {
            snapshot in
//            let resultValue = snapshot.value as? NSDictionary
//            if resultValue != nil {
//                let playerString = resultValue?["playerString"] as? String ?? ""
//
//                games.filter { $0.gameCode == gameCode }.first!.updatePlayers(playerString: playerString)
//            }
            guard let resultValue = snapshot.value else { return }
            //if resultValue != nil {
            do {
                let game = try JSONDecoder().decode(AvailableGame.self, from: resultValue as! Data)
                var gameToUpdate = games.filter { $0.gameCode == gameCode }.first!
                gameToUpdate = game
            } catch let error {
                print(error)
            }
            completion("")
        })
    }
}


