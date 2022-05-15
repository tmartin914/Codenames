//
//  Game.swift
//  Codenames
//
//  Created by Tyler Martin on 4/27/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import Foundation

/// Class for a game
class Game {
    /// List of players in game
    var players: [Player]
    
    /// List of blue players in game
    var bluePlayers: [Player] = []
    
    /// List of red payers in game
    var redPlayers: [Player] = []
    
    /// List of words in game
    var words: [String]? = []
    
    /// Game board as a list of cards
    var board: [Card]? = []
    
    /// Number of games the red team has won
    var redScore: Int
    
    /// Number of games the blue team has won
    var blueScore: Int
    
    /// Number of words the red team has left
    var redLeft: Int
    
    /// Number of words the blue team has left
    var blueLeft: Int
    
    /// Name of player whose turn it is
    var turn: String?
    
    /// The team that goes first
    var firstTeam: Team?
    
    /// Order of turns as a list of player names
    var turnOrder: [String]?
    
    /// Order of who goes first each game as a list of player names
    var firstTurnOrder: [String]?
    
    /// Total matches played
    var matchesPlayed: Int
    
    /// Current clue word
    var clue: String
    
    /// Current clue number of words to be guessed
    var numClue: Int
    
    /// Number of guessed left
    var guessesLeft: Int
    
    /// Flag indicating if the game was completed
    var gameCompleted: Bool
    
    /// Game ID as string
    var gameID: String
    
    /// Default Initializer
    init() {
        players = []
        redScore = 0
        blueScore = 0
        redLeft = 0
        blueLeft = 0
        matchesPlayed = 0
        gameCompleted = false
        clue = "-1"
        numClue = -1
        guessesLeft = -1
        gameID = ""
        words = getWordList()
    }
    
    /// Initializer given a game ID
    init(gameID: String) {
        self.gameID = gameID
        players = []
        redScore = 0
        blueScore = 0
        redLeft = 0
        blueLeft = 0
        matchesPlayed = 0
        gameCompleted = false
        clue = "-1"
        numClue = -1
        guessesLeft = -1
        words = getWordList()
    }
    
    /// Initializer given a game ID and list of players
    init(gameID: String, players: [Player]) {
        self.gameID = gameID
        self.players = players
        redScore = 0
        blueScore = 0
        redLeft = 0
        blueLeft = 0
        matchesPlayed = 0
        gameCompleted = false
        clue = "-1"
        numClue = -1
        guessesLeft = -1
        words = getWordList()
    }
    
    /// Returns the game data as a dictionary
    func getGameData() -> NSMutableDictionary {
        let gameData: NSMutableDictionary = [:]
        
        gameData["blueScore"] = String(blueScore)
        gameData["redScore"] = String(redScore)
        gameData["blueLeft"] = String(blueLeft)
        gameData["redLeft"] = String(redLeft)
        gameData["matchesPlayed"] = String(matchesPlayed)
        gameData["turn"] = turn
        gameData["clue"] = clue
        gameData["numClue"] = String(numClue)
        gameData["guessesLeft"] = String(guessesLeft)
        gameData["gameCompleted"] = gameCompleted.description
        
        var turnOrderString = ""
        var i = 0
        for turnString in turnOrder! {
            if i != 0 {
                turnOrderString.append(contentsOf: ",")
            }
            
            turnOrderString.append(contentsOf: turnString)
            i += 1
        }
        gameData["turnOrder"] = turnOrderString
        
        var firstTurnOrderString = ""
        i = 0
        for turnString in firstTurnOrder! {
            if i != 0 {
                firstTurnOrderString.append(contentsOf: ",")
            }
            
            firstTurnOrderString.append(contentsOf: turnString)
            i += 1
        }
        gameData["firstTurnOrder"] = firstTurnOrderString
        
        switch firstTeam! {
        case Team.blue:
            gameData["firstTeam"] = "blue"
        case Team.red:
            gameData["firstTeam"] = "red"
        }
        
        var boardString = ""
        i = 0
        for card in board! {
            if i != 0 {
                boardString.append(contentsOf: ";")
            }
            
            boardString.append(contentsOf: "\(card.word),\(card.color.rawValue),\(card.guessed.description)")
            
            i += 1
        }
        gameData["board"] = boardString
        
        var playersString = ""
        i = 0
        for player in players {
            if i != 0 {
                playersString.append(contentsOf: ";")
            }
            
            playersString.append(contentsOf: "\(player.name),\(player.team.rawValue),\(player.role!.rawValue)")
            
            i += 1
        }
        gameData["players"] = playersString
        
        return gameData
    }
    
    /// Processes game after a card was selected
    func selectionMade(player: Player, selectedIndex: Int) {
        let selectedCard = board![selectedIndex]
        board![selectedIndex].guessed = true
        
        if selectedCard.color == Color.blue {
            blueLeft -= 1
            if blueLeft == 0 {
                gameOver(winner: Team.blue)
            }
            
            if player.team == Team.blue {
                guessesLeft -= 1
                if guessesLeft == 0 {
                    nextTurn()
                }
            }
            else {
                nextTurn()
            }
        } else if selectedCard.color == Color.red {
            redLeft -= 1
            if redLeft == 0 {
                gameOver(winner: Team.red)
            }
            
            if player.team == Team.red {
                guessesLeft -= 1
                if guessesLeft == 0 {
                    nextTurn()
                }
            }
            else {
                nextTurn()
            }
        } else if selectedCard.color == Color.white {
            nextTurn()
        } else if selectedCard.color == Color.black {
            if player.team == Team.blue {
                gameOver(winner: Team.red)
            }
            else {
                gameOver(winner: Team.blue)
            }
        }
    }
    
    /// Handle the game ending
    func gameOver(winner: Team) {
        gameCompleted = true
        turn = "-1"
        matchesPlayed += 1
        
        if winner == Team.blue {
            blueScore += 1
        } else {
            redScore += 1
        }
    }
    
    /// Move to next turn
    func nextTurn() {
        var i = 1
        for turnString in turnOrder! {
            if turnString == turn {
                break
            }
            i += 1
        }
        
        if i == 4 {
            i = 0
        }
        
        let currentPlayer = players.filter { $0.name == turn }.first
        let nextPlayer = players.filter { $0.name == turnOrder![i] }.first
        if currentPlayer!.team != nextPlayer!.team {
            clearClue()
        }
        
        turn = turnOrder![i]
    }
    
    /// Clear the current clue
    func clearClue() {
        clue = "-1"
        numClue = -1
        guessesLeft = -1
    }
    
    /// Update the current game based off of values from the DB
    func update(board: String, blueScore: String, redScore: String, blueLeft: String, redLeft: String, turn: String, firstTeam: String, turnOrder: String, firstTurnOrder: String, matchesPlayed: String, clue: String, numClue: String, guessesLeft: String, gameCompleted: String, players: String) {
        self.blueScore = Int(blueScore)!
        self.redScore = Int(redScore)!
        self.blueLeft = Int(blueLeft)!
        self.redLeft = Int(redLeft)!
        self.matchesPlayed = Int(matchesPlayed)!
        self.turn = turn
        self.turnOrder = turnOrder.components(separatedBy: ",")
        self.firstTurnOrder = firstTurnOrder.components(separatedBy: ",")
        self.clue = clue
        self.numClue = Int(numClue)!
        self.guessesLeft = Int(guessesLeft)!
        
        if gameCompleted == "true" {
            self.gameCompleted = true
        } else {
            self.gameCompleted = false
        }
        
        switch firstTeam {
        case "blue":
            self.firstTeam = Team.blue
        case "red":
            self.firstTeam = Team.red
        default:
            self.firstTeam = nil
        }
        
        let cardStrings = board.components(separatedBy: ";")
        
        self.board = []
        for cardString in cardStrings {
            let attributeStrings = cardString.components(separatedBy: ",")
            self.board?.append(Card(word: attributeStrings[0], color: attributeStrings[1], guessed: attributeStrings[2]))
        }
        
        let playersStrings = players.components(separatedBy: ";")
        
        self.players = []
        for playerString in playersStrings {
            let attributeStrings = playerString.components(separatedBy: ",")
            self.players.append(Player(name: attributeStrings[0], team: attributeStrings[1], role: attributeStrings[2]))
        }
        
        setPlayers()
    }
    
    /// Create a enw game
    func createNewGame() {
        setPlayers()
        setFirstTurnOrder()
        startNewGame()
    }
    
    /// Put all players on appropriate team
    func setPlayers() {
        bluePlayers = []
        redPlayers = []
        for player in players {
            if player.team == Team.blue {
                bluePlayers.append(player)
            }
            else {
                redPlayers.append(player)
            }
        }
    }
    
    /// Get the team that goes first
    func getFirstTeam() -> Team {
        if firstTeam != nil {
            return (firstTeam == Team.blue) ? Team.red : Team.blue
        }
        else {
            //let num = Int.random(in: 0..<2)
            //return (num == 0) ? Team.blue : Team.red
            // TODO: this will need to be updated if we want it to be random
            return players[0].team
        }
    }
    
    /// Get list of game words
    func getWordList() -> [String] {
        if let path = Bundle.main.path(forResource: "allWords", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let words = data.components(separatedBy: .newlines).filter({ $0 != "" })
                return words
            } catch {
                print(error)
            }
        }
        return []
    }
    
    /// Set the first turn order
    func setFirstTurnOrder() {
        if players[0].team == Team.blue {
            firstTurnOrder = [bluePlayers[0].name, redPlayers[1].name, bluePlayers[1].name, redPlayers[0].name]
            turnOrder = [bluePlayers[0].name, bluePlayers[1].name, redPlayers[0].name, redPlayers[1].name]
        } else {
            firstTurnOrder = [redPlayers[0].name, bluePlayers[1].name, redPlayers[1].name, bluePlayers[0].name]
            turnOrder = [redPlayers[0].name, redPlayers[1].name, bluePlayers[0].name, bluePlayers[1].name]
        }
    }
    
    /// Get the teammate of the given player
    func getTeammate(player: Player) -> Player {
        if player.team == Team.blue {
            return bluePlayers.filter { $0.name != player.name }.first!
        } else {
            return redPlayers.filter { $0.name != player.name }.first!
        }
    }
    
    /// Start a new game
    func startNewGame() {
        gameCompleted = false
        firstTeam = getFirstTeam()
        redLeft = (firstTeam == Team.red) ? 9 : 8
        blueLeft = (firstTeam == Team.blue) ? 9 : 8
        
        turn = firstTurnOrder![matchesPlayed % 4]
        
        // Set Roles
        for player in players {
            player.role = Role.guesser
        }
        
        let cluer1 = players.filter { $0.name == turn }.first!
        let otherCluerName = getSameRole(player: cluer1).name
        let cluer2 = players.filter { $0.name == otherCluerName}.first!
        cluer1.role = Role.cluer
        cluer2.role = Role.cluer
        
        let guesser1 = getTeammate(player: cluer1)
        let guesser2 = getTeammate(player: cluer2)
        
        turnOrder = [cluer1.name, guesser1.name, cluer2.name, guesser2.name]
        
        createNewBoard()
    }
    
    /// Create a new game board
    func createNewBoard() {
        clearClue()
        
        let gameWords = words?.choose(25)
        
        let blueExtraColors = [Color.red, Color.blue, Color.black, Color.white, Color.red, Color.blue, Color.white, Color.red, Color.blue, Color.white, Color.red, Color.blue, Color.white, Color.red, Color.blue, Color.white, Color.red, Color.blue, Color.white, Color.red, Color.blue, Color.white, Color.red, Color.blue, Color.blue]
        
        let redExtraColors = [Color.red, Color.blue, Color.black, Color.white, Color.red, Color.blue, Color.white, Color.red, Color.blue, Color.white, Color.red, Color.blue, Color.white, Color.red, Color.blue, Color.white, Color.red, Color.blue, Color.white, Color.red, Color.blue, Color.white, Color.red, Color.blue, Color.red]
        
        let tempColors = (firstTeam == Team.blue) ? blueExtraColors : redExtraColors
        let gameColors = tempColors.shuffled()
        
        board?.removeAll()
        
        for i in 0...24 {
            let card = Card(word: gameWords![i], color: gameColors[i], guessed: false)
            board!.append(card)
        }
    }
    
    /// Get the number of words left given a team
    func getNumLeft(team: Team) -> Int {
        if team == .blue {
            return blueLeft
        }
        else {
            return redLeft
        }
    }
    
    /// Get the player in the game that has the same role as the given player
    func getSameRole(player: Player) -> Player {
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
}

/// Collection extension
extension Collection {
    func choose(_ num: Int) -> ArraySlice<Element> { shuffled().prefix(num) }
}




