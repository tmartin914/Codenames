//
//  PlayerGameTest.swift
//  CodenamesTests
//
//  Created by Tyler Martin on 5/13/22.
//  Copyright © 2022 Tyler Martin. All rights reserved.
//

import XCTest
@testable import Codenames

/// Class for testing PlayerGame
class PlayerGameTest: XCTestCase {
    
    /// PlayerGame for testing
    var playerGame: PlayerGame!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        playerGame = getTestPlayerGame()
    }

    override func tearDownWithError() throws {
        playerGame = nil
        try super.tearDownWithError()
    }

    /// Test getTeammate()
    func testGetTeammate() {
        // when
        let teammate = playerGame.getTeammate()
        
        // then
        XCTAssertEqual("brian", teammate)
    }
    
    /// Test updatePlayerString()
    func testUpdatePlayerString() {
        // given
        let differentPlayerString = "different player string"
        
        // when
        playerGame.updatePlayerString(playerString: differentPlayerString)
        
        // then
        XCTAssertEqual(differentPlayerString, playerGame.playerString)
    }
    
    /// Test updatePlayers()
    func testUpdatePlayers() {
        // given
        let differentPlayerString = "ty,red;zack,blue;brian,blue;matt,red"
        
        // when
        playerGame.updatePlayerString(playerString: differentPlayerString)
        playerGame.updatePlayers()
        
        // then
        XCTAssertEqual(4, playerGame.players.count)
        XCTAssertEqual(2, playerGame.team1.count)
        XCTAssertEqual(2, playerGame.team2.count)
        XCTAssertNotNil(playerGame.team1.first { $0.name == "ty"})
        XCTAssertNotNil(playerGame.team1.first { $0.name == "matt"})
        XCTAssertNotNil(playerGame.team2.first { $0.name == "zack"})
        XCTAssertNotNil(playerGame.team2.first { $0.name == "brian"})
    }
    
    // TODO: write remaining tests
    
    /// Returns a PlayerGame object for testing
    func getTestPlayerGame() -> PlayerGame {
        return PlayerGame(userID: "ty", gameID: "n/a", playerString: "ty,blue;zack,red;brian,blue;matt,red", turn: "n/a", timestamp: "01-01-2022 00:00:00", started: "n/a", completed: "n/a")!
    }
}
