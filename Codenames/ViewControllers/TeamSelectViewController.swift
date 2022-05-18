//
//  TeamSelectViewController.swift
//  Codenames
//
//  Created by Tyler Martin on 4/24/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import UIKit
import Firebase
import os.log

/// Team select view controller
@available(iOS 14.0, *)
class TeamSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /// Logger
    private let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: TeamSelectViewController.self)
    )
    
    /// Firebase reference
    var ref: DatabaseReference?
    
    /// Available games firebase reference
    var refAvailableGames: DatabaseReference?
    
    /// User ID
    var userID: String?
    
    /// Current user ID
    var currentUID: String?
    
    /// Game code
    var gameCode: String?
    
    /// Game ID
    var gameID: String?

    /// Number of blue team players
    @IBOutlet weak var bluePlayerCount: UILabel!
    
    /// Table of blue team player names
    @IBOutlet weak var bluePlayers: UITableView!
    
    /// Nuber of red team players
    @IBOutlet weak var redPlayerCount: UILabel!
    
    /// Table of red team player names
    @IBOutlet weak var redPlayers: UITableView!
    
    /// Join blue team button
    @IBOutlet weak var blueJoinBtn: UIButton!
    
    /// Join red team button
    @IBOutlet weak var redJoinBtn: UIButton!
    
    /// Start game button
    @IBOutlet weak var startGameBtn: UIButton!
    
    /// Reset teams button
    @IBOutlet weak var resetTeamsBtn: UIButton!
    
    /// Game code field
    @IBOutlet weak var gameCodeField: UILabel!
    
    /// Back button
    @IBOutlet weak var backBtn: UIButton!
    
    /// Game code label
    @IBOutlet weak var gameCodeLabel: UILabel!
    
    /// Blue team label
    @IBOutlet weak var blueLabel: UILabel!
    
    /// Red team label
    @IBOutlet weak var redLabel: UILabel!
    
    /// Join blue team
    @IBAction func joinBlue(_ sender: Any) {
        joinTeam(team: "blue")
    }
    
    /// Join red team
    @IBAction func joinRed(_ sender: Any) {
        joinTeam(team: "red")
    }
    
    /// Segue to game view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueConstants.SHOW_GAME_SEGUE {
            if let destinationVC = segue.destination as? GameViewController {
                //destinationVC.game = GameManager.getGame(gameID: AvailableGameManager.getGame(gameCode: gameCode!).gameID)
                destinationVC.game = GameManager.getGame(gameID: gameID!)
            }
        }
    }
    
    /// Join given team
    func joinTeam(team: String) {
        AvailableGameManager.getGame(gameCode: gameCode!).updatePlayerString(userID: userID!, team: team)
        //AvailableGameManager.recordGameStatus(gameCode: gameCode!)
        
        let gameData = AvailableGameManager.getGame(gameCode: gameCode!).getGameData()
        
        refAvailableGames!.child(gameCode!).setValue(gameData, withCompletionBlock: { (error:Error?, dbRef:DatabaseReference?) in
            if let error = error {
                self.logger.error("Data could not be saved: \(error.localizedDescription).")
            }
            else {
                if AvailableGameManager.getGame(gameCode: self.gameCode!).bluePlayers.count == 2 && AvailableGameManager.getGame(gameCode: self.gameCode!).redPlayers.count == 2 {
                    self.createGame()
                }
            }
        })
        
        PlayerGameManager.joinGame(userID: userID!, gameID: gameID!, playerString: gameData["playerString"] as! String)
        //PlayerGameManager.getGame(gameID: gameID!).updatePlayerString(playerString: gameData["playerString"]! as! String)
        //PlayerGameManager.recordPlayerGameStatus(playerID: userID!, gameID: gameID!)
    }
    
    /// Segue to home view
    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: SegueConstants.BACK_TO_HOME_SEGUE, sender: self)
    }
    
    /// Start game
    @IBAction func startGame(_ sender: Any) {
        /*let game = AvailableGameManager.getGame(gameCode: gameCode!)
        GameManager.updateGame(gameID: game.gameID) { (result:String) in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showGame", sender: self)
            }
        }*/
        self.performSegue(withIdentifier: SegueConstants.SHOW_GAME_SEGUE, sender: self)
    }
    
    /// Reset teams
    @IBAction func resetTeams(_ sender: Any) {
        AvailableGameManager.getGame(gameCode: gameCode!).clearPlayers()
        AvailableGameManager.recordGameStatus(gameCode: gameCode!)
        self.updatePlayers()
        
        PlayerGameManager.removeGame(gameID: gameID!, userID: userID!)
        //PlayerGameManager.recordPlayerGameStatus(playerID: userID!, gameID: gameID!)
    }
    
    /// Create new game
    func createGame() {
        let availableGame = AvailableGameManager.getGame(gameCode: gameCode!)
        availableGame.setInitialRoles()
        let game = Game(gameID: availableGame.gameID, players: availableGame.getAllPlayers())
        game.createNewGame()
        GameManager.games.append(game)
        GameManager.recordGameStatus(gameID: game.gameID)
    }
    
    /// Update players in game
    func updatePlayers() {
        let game = AvailableGameManager.getGame(gameCode: gameCode!)
        
        bluePlayerCount.text = "\(game.bluePlayers.count) / 2"
        bluePlayerCount.setNeedsDisplay()
        redPlayerCount.text = "\(game.redPlayers.count) / 2"
        redPlayerCount.setNeedsDisplay()
        
        bluePlayers.reloadData()
        redPlayers.reloadData()
        
        blueJoinBtn.isHidden = (game.bluePlayers.count == 2 || game.isInGame(userId: userID!))
        redJoinBtn.isHidden = (game.redPlayers.count == 2 || game.isInGame(userId: userID!))
        blueJoinBtn.setNeedsDisplay()
        redJoinBtn.setNeedsDisplay()
        
        startGameBtn.isHidden = !(game.bluePlayers.count == 2 && game.redPlayers.count == 2)
        
        gameCodeField.text = "\(game.gameCode)"
        gameCodeField.setNeedsDisplay()
    }
    
    /// On view appearing
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        blueJoinBtn.isHidden = true;
        redJoinBtn.isHidden = true;
        startGameBtn.isHidden = true;
        
        AvailableGameManager.watchGame(gameCode: gameCode!){ (result:String) in
            DispatchQueue.main.async {
                self.updatePlayers();
            }
        }
    }
    
    /// On view laoding
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: ResourceConstants.DARK_TABLE_IMAGE)!)
        
        let buttons = [backBtn, startGameBtn, resetTeamsBtn, redJoinBtn, blueJoinBtn]
        for button in buttons {
            button!.layer.cornerRadius = 5
            button!.layer.borderWidth = 1
            button!.layer.borderColor = UIColor.black.cgColor
        }
        
        let teamLabels = [blueLabel, redLabel]
        for teamLabel in teamLabels {
            teamLabel!.layer.cornerRadius = 5
            teamLabel!.layer.borderWidth = 1
            teamLabel!.layer.borderColor = UIColor.black.cgColor
            teamLabel!.layer.masksToBounds = true
        }
        
        let labels = [bluePlayerCount, redPlayerCount, gameCodeField, gameCodeLabel]
        for label in labels {
            label!.textColor = UIColor.white
        }
        
        /*let viewWidth = self.view.frame.size.width
        let origin = blueLabel.frame.origin
        let originx = origin.x
        let originy = origin.y
        print("\(originx) \(origin.y)")
        blueLabel.frame.origin = CGPoint(x: viewWidth/4, y: origin.y)
        redLabel.frame.origin = CGPoint(x: viewWidth*3/4, y: origin.y)*/
        
        blueJoinBtn.isHidden = true;
        redJoinBtn.isHidden = true;
        startGameBtn.isHidden = true;
        
        ref = Database.database().reference()
        refAvailableGames = ref?.child("AvailableGames")
        
        currentUID = Auth.auth().currentUser!.uid
        
        //let displayName = Auth.auth().currentUser!.displayName
        userID = Auth.auth().currentUser!.email?.components(separatedBy: "@")[0]
        
        self.updatePlayers();
    }
    
    // UITableViewDataSource Methods
    
    /// Return number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    /// Return cell at index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let game = AvailableGameManager.getGame(gameCode: gameCode!)
        
        if tableView == self.bluePlayers {
            if game.bluePlayers.indices.contains(indexPath.row) {
                cell.textLabel?.text = game.bluePlayers[indexPath.row].name
            }
        }
        else {
            if game.redPlayers.indices.contains(indexPath.row) {
                cell.textLabel?.text = game.redPlayers[indexPath.row].name
            }
        }
        
        return cell
    }
}
