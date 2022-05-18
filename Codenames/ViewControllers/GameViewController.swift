//
//  GameViewController.swift
//  Codenames
//
//  Created by Tyler Martin on 4/24/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import UIKit
import Firebase
import os.log

/// Game view controller
@available(iOS 14.0, *)
class GameViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// Logger
    private let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: GameViewController.self)
    )
    
    /// User ID
    var userID: String?
    
    /// Current user ID
    var currentUID: String?
    
    /// Game
    var game = Game()
    
    /// Current player
    var currentPlayer: Player?
    
    /// Firebase reference
    var ref: DatabaseReference?
    
    /// Games firebase reference
    var refGames: DatabaseReference?
    
    /// Game collection view
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// Back button
    @IBOutlet weak var backBtn: UIButton!
    
    /// Turn label
    @IBOutlet weak var turnLabel: UILabel!
    
    /// Score label
    @IBOutlet weak var scoreLabel: UILabel!
    
    /// Words left label
    @IBOutlet weak var wordsLeftLabel: UILabel!
    
    /// Clue field
    @IBOutlet weak var clueField: UITextField!
    
    // TODO: maybe make a picker - (up to num left)
    /// Number of guesses left field
    @IBOutlet weak var numField: UITextField!
    
    /// Submit button
    @IBOutlet weak var submitBtn: UIButton!
    
    /// New game button
    @IBOutlet weak var newGameBtn: UIButton!
    
    /// Pass turn button
    @IBOutlet weak var passBtn: UIButton!
    
    /// Start new game
    @IBAction func startNewGame(_ sender: Any) {
        game.startNewGame()
        GameManager.recordGameStatus(gameID: game.gameID)
    }
    
    /// Segue to home view
    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: SegueConstants.BACK_TO_HOME_SEGUE, sender: self)
    }
    
    /// Submit guess
    @IBAction func submit(_ sender: Any) {
        if (currentPlayer!.role == Role.cluer) {
            let numLeft = game.getNumLeft(team: currentPlayer!.team)
            if Int(numField.text!) == nil {
                let alert = UIAlertController(title: "Invalid Clue Number", message: "\(numField.text!) is not a number!", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.logger.error("Invalid clue number. \(self.numField.text!) is not a number")
            }
            else if Int(numField.text!)! <= 0 {
                let alert = UIAlertController(title: "Invalid Clue Number", message: "Number of guesses should be > 0", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.logger.error("Invalid clue number. Number of guesses should be > 0")
            }
            else if Int(numField.text!)! > numLeft {
                let alert = UIAlertController(title: "Invalid Clue Number", message: "Number of guesses should be < \(numLeft)!", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.logger.error("Invalid clue number. Number of guesses should be < \(numLeft)")
            }
            else if clueField.text! == "" {
                let alert = UIAlertController(title: "Invalid Clue", message: "No clue entered!", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.logger.error("Invalid clue number. No clue entered")
            }
            else {
                game.nextTurn()
                game.clue = clueField.text!
                game.numClue = Int(numField.text!)!
                game.guessesLeft = Int(numField.text!)!
                GameManager.recordGameStatus(gameID: game.gameID)
            }
        } else {
            if collectionView.indexPathsForSelectedItems == nil || collectionView.indexPathsForSelectedItems?.first?.item == nil {
                let alert = UIAlertController(title: "No Word Selected", message: "Please select a word!", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.logger.error("No word selected")
            }
            else {
                let selectedIndex = collectionView.indexPathsForSelectedItems?.first?.item
                game.selectionMade(player: currentPlayer!, selectedIndex: selectedIndex!)
                GameManager.recordGameStatus(gameID: game.gameID)
            }
        }
    }
    
    /// Pass turn
    @IBAction func pass(_ sender: Any) {
        game.nextTurn()
        GameManager.recordGameStatus(gameID: game.gameID)
    }
    
    /// Set game
    func setGame() {
        // Update Turn
        turnLabel.text = "Turn: " + game.turn!
        turnLabel.setNeedsDisplay()
        
        if currentPlayer!.role! == .cluer && (game.turn! == currentPlayer?.name || game.turn! == currentPlayer?.name.lowercased()) {
            clueField.isEnabled = true
            numField.isEnabled = true
        } else {
            clueField.isEnabled = false
            numField.isEnabled = false
        }
        
        // Update Scores
        let blueScoreLen = String(game.blueScore).count
        let redScoreLen = String(game.redScore).count
        
        let scoreString = NSMutableAttributedString(string: "Score: \(String(describing: game.blueScore)) : \(String(describing: game.redScore))")
        scoreString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: NSMakeRange(7, blueScoreLen))
        scoreString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSMakeRange(10 + blueScoreLen, redScoreLen))
        
        scoreLabel.attributedText = scoreString
        scoreLabel.setNeedsDisplay()
        
        // Update Words Left
        let blueLeftLen = String(game.blueLeft).count
        let redLeftLen = String(game.redLeft).count
        
        let wordsLeftString = NSMutableAttributedString(string: "Words Left: \(String(describing: game.blueLeft)) : \(String(describing: game.redLeft))")
        wordsLeftString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: NSMakeRange(12, blueLeftLen))
        wordsLeftString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSMakeRange(15 + blueLeftLen, redLeftLen))
        
        wordsLeftLabel.attributedText = wordsLeftString
        wordsLeftLabel.setNeedsDisplay()
        
        // Update Clues
        if game.clue != "-1" {
            clueField.text = game.clue
            numField.text = String(game.numClue - game.guessesLeft) + "/" + String(game.numClue)
        } else {
            clueField.text = nil
            numField.text = nil
        }
        
        newGameBtn.isHidden = !(game.gameCompleted)
        
        submitBtn.isHidden = !(currentPlayer?.name == game.turn!) || game.gameCompleted
        passBtn.isHidden = !(currentPlayer?.name == game.turn! && currentPlayer?.role == .guesser) || game.gameCompleted
        
        turnLabel.isHidden = game.gameCompleted
        clueField.isHidden = game.gameCompleted
        numField.isHidden = game.gameCompleted
        
        collectionView.reloadData()
    }
    
    /// Set current player
    func setCurrentPlayer() {
        currentUID = Auth.auth().currentUser!.uid
        
        //let displayName = Auth.auth().currentUser!.displayName
        userID = Auth.auth().currentUser!.email?.components(separatedBy: "@")[0]
        
        for player in game.players {
            if player.name == userID || player.name.lowercased() == userID {
                currentPlayer = player
            }
        }
    }
    
    /// On view appearing
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        turnLabel.isHidden = true
        clueField.isHidden = true
        numField.isHidden = true
        newGameBtn.isHidden = true
        submitBtn.isHidden = true
        passBtn.isHidden = true
        
        GameManager.updateGame(gameID: game.gameID) { (result:String) in
            DispatchQueue.main.async {
                self.setGame();
            }
        }
    }
    
    // UICollectionViewDataSource methods
    
    /// Return number of items in section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        setCurrentPlayer()
        setGame()
        return 25
    }
    
    /// Return cell at index
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gameCell", for: indexPath) as! GameCell
        //setCurrentPlayer()
        cell.setup(game: game, card: (game.board![indexPath.item]), role: currentPlayer!.role!)
        return cell
    }
    
    /// Return cell size at index
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 5
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let space = flowLayout.minimumInteritemSpacing * (columns - 1)
        let adjWidth = collectionView.bounds.width - space
        let adjHeight = collectionView.bounds.height - space
        let width: CGFloat = floor(adjWidth / columns)
        let height: CGFloat = floor(adjHeight / columns)
        return CGSize(width: width, height: height)
    }
    
    /// Handle item being selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentPlayer?.role == Role.guesser && !game.gameCompleted && (currentPlayer?.name == game.turn || currentPlayer?.name.lowercased() == game.turn) {
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 3.0
            cell?.layer.borderColor = UIColor.gray.cgColor
        }
    }
    
    /// Handle item being deselected
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0.0
    }
    
    /// Return whether a card can be selected
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return !game.board![indexPath.item].guessed
    }
    
    /// On view loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUID = Auth.auth().currentUser!.uid
        
        setCurrentPlayer()
        
        // TODO: give them background options - to start maybe do dark for guesser and light for cluer
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: ResourceConstants.DARK_TABLE_IMAGE)!)
        
        collectionView.backgroundColor = UIColor.clear
        
        ref = Database.database().reference()
        refGames = ref?.child("Games")
        
        clueField.autocorrectionType = .no
        
        let buttons = [backBtn, submitBtn, newGameBtn, passBtn]
        for button in buttons {
            button!.layer.cornerRadius = 5
            button!.layer.borderWidth = 1
            button!.layer.borderColor = UIColor.black.cgColor
        }
        
        let labels = [scoreLabel, wordsLeftLabel, turnLabel]
        for label in labels {
            label!.layer.cornerRadius = 5
            label!.layer.borderWidth = 1
            label!.layer.borderColor = UIColor.black.cgColor
            // TODO: what color should they be - should it vary based off role/background
            //label!.backgroundColor = UIColor(red: 245, green: 222, blue: 179)
            label!.layer.masksToBounds = true
        }
    }
}
