//
//  GameTest.swift
//  CodenamesTests
//
//  Created by Tyler Martin on 5/15/22.
//  Copyright © 2022 Tyler Martin. All rights reserved.
//

import XCTest
@testable import Codenames

class GameTest: XCTestCase {
    var game: Game!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        game = getTestGame()
    }

    override func tearDownWithError() throws {
        game = nil
        try super.tearDownWithError()
    }

    /// Test updatePlayers()
    func testGameOver() {
        // when/then
        game.gameOver(winner: Team.blue)
        XCTAssert(game.gameCompleted)
        XCTAssertEqual("-1", game.turn)
        XCTAssertEqual(1, game.blueScore)
        XCTAssertEqual(0, game.redScore)
        XCTAssertEqual(1, game.matchesPlayed)
        
        game.gameOver(winner: Team.red)
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
    
    /// Returns a Game object for testing
    func getTestGame() -> Game {
        var players : [Player] = []
        players.append(Player(name: "ty", team: Team.blue, role: Role.cluer))
        players.append(Player(name: "zack", team: Team.blue, role: Role.guesser))
        players.append(Player(name: "matt", team: Team.red, role: Role.cluer))
        players.append(Player(name: "brian", team: Team.red, role: Role.guesser))
        return Game(gameID: "ABCD", players: players)
    }
}
