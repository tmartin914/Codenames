//
//  GameInfoCell.swift
//  Codenames
//
//  Created by Tyler Martin on 6/5/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import UIKit

class GameInfoCell: UICollectionViewCell {
    
    @IBOutlet weak var team1Label: UILabel!
    @IBOutlet weak var team2Label: UILabel!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var turnTextLabel: UILabel!
    
    var gameID: String = ""
    
    func setup(game: PlayerGame) {
        gameID = game.gameID
        
        layer.cornerRadius = 10
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.black.cgColor
        backgroundColor = UIColor(red: 245, green: 222, blue: 179)
        
        if game.team1.count == 1 {
            team1Label.text = "You"
        } else {
            team1Label.text = "You & \(game.getTeammate())"
        }
        
        if game.team2.count == 1 {
            team2Label.text = game.team2[0].name
        } else if game.team2.count == 2 {
            team2Label.text = game.team2[0].name + " & " + game.team2[1].name
        } else {
            team2Label.text = ""
        }
        
        // TODO: show series score when gameCompleted
        if game.turn != "-1" {
            turnLabel.text = game.turn
            turnLabel.isHidden = false
            turnTextLabel.isHidden = false
        } else {
            turnLabel.isHidden = true
            turnTextLabel.isHidden = true
        }
        
        turnLabel.setNeedsDisplay()
        team1Label.setNeedsDisplay()
        team2Label.setNeedsDisplay()
    }
}
