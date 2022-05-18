//
//  HomeViewController.swift
//  Codenames
//
//  Created by Tyler Martin on 6/4/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import UIKit
import Firebase
import os.log

/// Home view controller
@available(iOS 14.0, *)
class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// Logger
    private let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: HomeViewController.self)
    )
    
    /// User ID
    var userID: String?
    
    /// Current user ID
    var currentUID: String?
    
    /// Game code (4 characters string)
    var gameCode: String?
    
    /// Game ID
    var gameID: String?
    
    /// Flag indicating whether to go to team select screen
    var goToTeamSelect = false
    
    /// Flag indicating if games have been loaded
    var gamesLoaded = false
    
    /// New game button
    @IBOutlet weak var newGameBtn: UIButton!
    
    /// Game code field
    @IBOutlet weak var gameCodeField: UITextField!
    
    /// Join button
    @IBOutlet weak var joinBtn: UIButton!
    
    /// Logout button
    @IBOutlet weak var logoutBtn: UIButton!
    
    /// Collection view of not started games
    @IBOutlet weak var notStartedCollectionView: UICollectionView!
    
    /// Collection view of in progress games
    @IBOutlet weak var inProgressCollectionView: UICollectionView!
    
    /// Collection view of completed games
    @IBOutlet weak var completedCollectionView: UICollectionView!
    
    /// Not started label
    @IBOutlet weak var notStartedLabel: UILabel!
    
    /// In progress label
    @IBOutlet weak var inProgressLabel: UILabel!
    
    /// Completed label
    @IBOutlet weak var completedLabel: UILabel!
    
    /// Logout
    @IBAction func logout(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: SegueConstants.SHOW_LOGIN_SEGUE, sender: self)
        }
        catch let signOutError as NSError{
            self.logger.error("Error signing out: \(signOutError)")
        }
    }
    
    /// Create new game
    @IBAction func newGame(_ sender: Any) {
        let (tempGameCode,tempGameID) = AvailableGameManager.createNewGame(userID: userID!)
        gameCode = tempGameCode
        gameID = tempGameID
        PlayerGameManager.createNewGame(userID: userID!, gameID: gameID!)
        //gameID = AvailableGameManager.getGame(gameCode: gameCode!).gameID
        /*AvailableGameManager.watchGames() { (result:String) in
            DispatchQueue.main.async {
                 self.performSegue(withIdentifier: "showTeamSelect", sender: self)
            }
        }*/
        goToTeamSelect = true
    }
    
    /// Join game
    @IBAction func join(_ sender: Any) {
        if gameCodeField.text! == "" {
            let alert = UIAlertController(title: "Invalid Game Code", message: "No game code entered!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            self.logger.error("No game code entered")
        } else if gameCodeField.text!.count != 4 {
            let alert = UIAlertController(title: "Invalid Game Code", message: "Game code should be 4 characters", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            self.logger.error("Invalid game code. Game code should be 4 characters")
        } else if AvailableGameManager.isGameCode(gameCode: gameCodeField.text!) {
            gameCode = gameCodeField.text!
            gameID = AvailableGameManager.getGame(gameCode: gameCode!).gameID
            self.performSegue(withIdentifier: "showTeamSelect", sender: self)
        } else {
            let alert = UIAlertController(title: "Invalid Game Code", message: "No game codes match \(gameCodeField.text!)!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            self.logger.error("Invalid game code. No game codes match \(self.gameCodeField.text!)")
        }
    }
    
    /// Go to the given page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueConstants.SHOW_TEAM_SELECT_SEGUE {
            if let destinationVC = segue.destination as? TeamSelectViewController {
                destinationVC.gameCode = gameCode!
                destinationVC.gameID = gameID!
            }
        } else if segue.identifier == SegueConstants.SHOW_GAME_SEGUE {
            if let destinationVC = segue.destination as? GameViewController {
                destinationVC.game = GameManager.getGame(gameID: gameID!)
            }
        }
    }
    
    /// Update all game lists
    func updateGames() {
        notStartedCollectionView.reloadData()
        inProgressCollectionView.reloadData()
        completedCollectionView.reloadData()
    }
    
    /// On view appearing
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        goToTeamSelect = false
        AvailableGameManager.watchGames(){ (result:String) in
            DispatchQueue.main.async {
                self.updateGames();
                if self.goToTeamSelect {
                    self.performSegue(withIdentifier: SegueConstants.SHOW_TEAM_SELECT_SEGUE, sender: self)
                }
            }
        }
    }
    
    /// On view loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: ResourceConstants.DARK_TABLE_IMAGE)!)
        
        let buttons = [newGameBtn, logoutBtn, joinBtn]
        for button in buttons {
            button!.layer.cornerRadius = 5
            button!.layer.borderWidth = 1
            button!.layer.borderColor = UIColor.black.cgColor
        }
        
        let labels = [notStartedLabel, inProgressLabel, completedLabel]
        for label in labels {
            label!.textColor = UIColor.white
        }
        
        GameManager.loadGames() { (result:String) in
            
        }
        
        currentUID = Auth.auth().currentUser!.uid
        userID = Auth.auth().currentUser!.email?.components(separatedBy: "@")[0]
        
        /*PlayerGameManager.loadGames(userID: userID!) { (result:String) in

        }*/
        
        self.updateGames();
    }
    
    // UICollectionViewDataSource methods
    
    /// Returns number of sections in collection view
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /// Returns number of items in each section of collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let (notStarted, inProgress, completed) = PlayerGameManager.getGameStatusData()
        
        if collectionView == notStartedCollectionView {
            return notStarted
        } else if collectionView == inProgressCollectionView {
            return inProgress
        } else if collectionView == completedCollectionView {
            return completed
        }
        
        return 0
    }
    
    /// Returns cells at each index of collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var status = GameStatus.notStarted
        if collectionView == notStartedCollectionView {
            status = .notStarted
        } else if collectionView == inProgressCollectionView {
            status = .inProgress
        } else if collectionView == completedCollectionView {
            status = .completed
        }
        
        let game = PlayerGameManager.getGameByStatus(status: status, index: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gameInfoCell", for: indexPath) as! GameInfoCell
        cell.setup(game: game)
        
        return cell
    }
    
    /*func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeader", for: indexPath) as! GameSectionHeader
        /*headerView.setup(section: indexPath.section)
        headerView.backgroundColor = UIColor.blue
        return headerView*/
        
        if collectionView == notStartedCollectionView {
            headerView.headerLabel.text = "Not Started:"
        } else if collectionView == inProgressCollectionView {
            headerView.headerLabel.text = "In Progress:"
        } else if collectionView == completedCollectionView {
            headerView.headerLabel.text = "Completed:"
        }
        
        return headerView
    }*/
    
    /// Returns size of collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: collectionView.frame.height)
    }
    
    /// Performs segue based off item that was clicked
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GameInfoCell
        gameID = cell.gameID
        
        if GameManager.isGameID(gameID: gameID!) {
            self.performSegue(withIdentifier: "showGame", sender: self)
        } else {
            gameCode = AvailableGameManager.getGameCode(gameID: gameID!)
            self.performSegue(withIdentifier: "showTeamSelect", sender: self)
        }
        
    }
}
