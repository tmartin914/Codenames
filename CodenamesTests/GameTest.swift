//
//  GameTest.swift
//  CodenamesTests
//
//  Created by Tyler Martin on 5/15/22.
//  Copyright © 2022 Tyler Martin. All rights reserved.
//

import XCTest
@testable import Codenames

/// Class for testing Game
class GameTest: XCTestCase {
    
    /// Game for testing
    var game: Game!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        game = GameTest.getTestGame()
    }

    override func tearDownWithError() throws {
        game = nil
        try super.tearDownWithError()
    }

    /// Test updatePlayers()
    func testGameOver() {
        // when
        game.gameOver(winner: Team.blue)
        
        // then
        XCTAssert(game.gameCompleted)
        XCTAssertEqual("-1", game.turn)
        XCTAssertEqual(1, game.blueScore)
        XCTAssertEqual(0, game.redScore)
        XCTAssertEqual(1, game.matchesPlayed)
        
        // when
        game.gameOver(winner: Team.red)
        
        // then
        XCTAssertEqual(1, game.blueScore)
        XCTAssertEqual(1, game.redScore)
        XCTAssertEqual(2, game.matchesPlayed)
    }
    
    /// Test nextTurn() going from cluer to guesser
    func testNextTurnSameTeam() {
        // given
        game.turnOrder = ["ty","zack","brian","matt"]
        game.turn = "ty"
        game.clue = "clue"
        game.numClue = 2
        game.guessesLeft = 2
        
        // when
        game.nextTurn()
        
        // then
        XCTAssertEqual("zack", game.turn)
        XCTAssertEqual("clue", game.clue)
        XCTAssertEqual(2, game.numClue)
        XCTAssertEqual(2, game.guessesLeft)
    }
    
    /// Test nextTurn() going from guesser to cluer
    func testNextTurnOtherTeam() {
        // given
        game.turnOrder = ["ty","zack","brian","matt"]
        game.turn = "zack"
        game.clue = "clue"
        game.numClue = 2
        game.guessesLeft = 2
        
        // when
        game.nextTurn()
        
        // then
        XCTAssertEqual("brian", game.turn)
        XCTAssertEqual("-1", game.clue)
        XCTAssertEqual(-1, game.numClue)
        XCTAssertEqual(-1, game.guessesLeft)
    }
    
    /// Test clearClue()
    func testClearClue() {
        // given
        game.clue = "clue"
        game.numClue = 2
        game.guessesLeft = 2
        
        // when
        game.clearClue()
        
        // then
        XCTAssertEqual("-1", game.clue)
        XCTAssertEqual(-1, game.numClue)
        XCTAssertEqual(-1, game.guessesLeft)
    }
    
    /// Test setPlayers()
    func testSetPlayers() {
        // when
        game.setPlayers()
        
        // then
        XCTAssertEqual(2, game.bluePlayers.count)
        XCTAssertEqual(2, game.redPlayers.count)
        XCTAssertNotNil(game.bluePlayers.first { $0.name == "ty"})
        XCTAssertNotNil(game.bluePlayers.first { $0.name == "zack"})
        XCTAssertNotNil(game.redPlayers.first { $0.name == "matt"})
        XCTAssertNotNil(game.redPlayers.first { $0.name == "brian"})
    }
    
    /// Test getFirstTeam()
    func testGetFirstTeam() {
        // given
        game.firstTeam = Team.blue
        
        // when
        var firstTeam = game.getFirstTeam()
        
        // then
        XCTAssertEqual(Team.blue, firstTeam)
        
        // given
        game.firstTeam = Team.red
        
        // when
        firstTeam = game.getFirstTeam()
        
        // then
        XCTAssertEqual(Team.red, firstTeam)
    }
    
    /// Test getWordList()
    func testGetWordList() {
        // when
        let wordList = game.getWordList()
        
        // then
        XCTAssertEqual(187, wordList.count)
    }
    
    // TODO: write remaining tests
    
    /// Returns a Game object for testing
    static func getTestGame() -> Game {
        var players : [Player] = []
        players.append(Player(name: "ty", team: Team.blue, role: Role.cluer))
        players.append(Player(name: "zack", team: Team.blue, role: Role.guesser))
        players.append(Player(name: "matt", team: Team.red, role: Role.cluer))
        players.append(Player(name: "brian", team: Team.red, role: Role.guesser))
        return Game(gameID: "ABCD", players: players)
    }
}
