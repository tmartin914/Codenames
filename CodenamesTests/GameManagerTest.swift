//
//  GameManagerTest.swift
//  CodenamesTests
//
//  Created by Tyler Martin on 5/20/22.
//  Copyright © 2022 Tyler Martin. All rights reserved.
//

import XCTest
@testable import Codenames

/// Class for testing GameManager
class GameManagerTest: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        setupTestGameManager()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    /// Test isGameID()
    func testIsGameID() {
        // when
        let isABCDGameID = GameManager.isGameID(gameID: "ABCD")
        let isDBCAGameID = GameManager.isGameID(gameID: "DCBA")
        
        // then
        XCTAssertTrue(isABCDGameID)
        XCTAssertFalse(isDBCAGameID)
    }
    
    /// Test getGame()
    func testGetGame() {
        // when
        let game = GameManager.getGame(gameID: "EFGH")
        
        // then
        XCTAssertNotNil(game)
        XCTAssertEqual("EFGH", game.gameID)
        XCTAssertEqual(4, game.players.count)
    }

    /// Returns a Game object for testing
    func setupTestGameManager() {
        let testGame1 = GameTest.getTestGame()
        let testGame2 = GameTest.getTestGame()
        testGame2.gameID = "EFGH"
        
        GameManager.games.append(testGame1)
        GameManager.games.append(testGame2)
    }
}
