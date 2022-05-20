//
//  GameCell.swift
//  Codenames
//
//  Created by Tyler Martin on 5/6/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import UIKit

/// Class for a game cell
class GameCell: UICollectionViewCell {
    
    /// Word label
    @IBOutlet weak var wordLabel: UILabel!
    
    /// Setup game cell
    func setup(game: Game, card: Card, role: Role) {
        wordLabel.attributedText = nil
        wordLabel.text = card.word
        wordLabel.adjustsFontSizeToFitWidth = true
        wordLabel.frame.size.width = self.bounds.width - 10
        layer.cornerRadius = 10
        layer.borderWidth = 0.0
        layer.borderColor = UIColor.black.cgColor
        
        if role == Role.cluer || game.gameCompleted {
            switch card.color {
            case Color.blue:
                self.backgroundColor = UIColor.blue
                wordLabel.textColor = UIColor.white
            case Color.red:
                self.backgroundColor = UIColor.red
                wordLabel.textColor = UIColor.white
            case Color.white:
                self.backgroundColor = UIColor.lightGray
                wordLabel.textColor = UIColor.black
            case Color.black:
                self.backgroundColor = UIColor.black
                wordLabel.textColor = UIColor.white
            }
            
            if card.guessed {
                let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: card.word)
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                wordLabel.attributedText = attributeString
            }
        } else {
            if card.guessed {
                switch card.color {
                case Color.blue:
                    self.backgroundColor = UIColor.blue
                    wordLabel.textColor = UIColor.white
                case Color.red:
                    self.backgroundColor = UIColor.red
                    wordLabel.textColor = UIColor.white
                case Color.white:
                    self.backgroundColor = UIColor.lightGray
                    wordLabel.textColor = UIColor.black
                case Color.black:
                    self.backgroundColor = UIColor.black
                    wordLabel.textColor = UIColor.white
                }
            } else {
                self.backgroundColor = UIColor(red: 245, green: 222, blue: 179)
                wordLabel.textColor = UIColor.black
            }
        }
    }
}

/// Color extension
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}
