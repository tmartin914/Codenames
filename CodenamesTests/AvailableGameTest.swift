//
//  AvailableGameTest.swift
//  CodenamesTests
//
//  Created by Tyler Martin on 5/15/22.
//  Copyright © 2022 Tyler Martin. All rights reserved.
//

import XCTest
@testable import Codenames

/// Class for testing AvailableGame
class AvailableGameTest: XCTestCase {
    
    /// AvailableGame for testing
    var availableGame: AvailableGame!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        availableGame = getTestAvailableGame()
    }

    override func tearDownWithError() throws {
        availableGame = nil
        try super.tearDownWithError()
    }

    /// Test isInGame()
    func testIsInGame() {
        // when
        let isBrianInGame = availableGame.isInGame(userId: "brian")
        let isBrettInGame = availableGame.isInGame(userId: "brett")
        
        // then
        XCTAssert(isBrianInGame)
        XCTAssert(!isBrettInGame)
    }
    
    /// Test getAllPlayers()
    func testGetAllPlayers() {
        // when
        let players = availableGame.getAllPlayers()
        
        // then
        XCTAssertEqual(4, players.count)
        XCTAssertNotNil(players.first { $0.name == "ty"})
        XCTAssertNotNil(players.first { $0.name == "matt"})
        XCTAssertNotNil(players.first { $0.name == "zack"})
        XCTAssertNotNil(players.first { $0.name == "brian"})
    }
    
    /// Test updatePlayerString()
    func testUpdatePlayerString() {
        // given
        availableGame.playerString = ""
        
        // when
        availableGame.updatePlayerString(userID: "matt", team: "blue")
        
        // then
        XCTAssertEqual("matt,blue", availableGame.playerString)
        
        // when
        availableGame.updatePlayerString(userID: "zack", team: "red")
        
        // then
        XCTAssertEqual("matt,blue;zack,red", availableGame.playerString)
    }
    
    // TODO: write remaining tests
    
    /// Returns a AvailableGame object for testing
    func getTestAvailableGame() -> AvailableGame {
        return AvailableGame(gameCode: "ABCD", gameID: "A123456", playerString: "ty,blue;zack,red;brian,blue;matt,red")
    }
}
