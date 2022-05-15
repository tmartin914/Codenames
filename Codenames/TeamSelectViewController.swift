//
//  TeamSelectViewController.swift
//  Codenames
//
//  Created by Tyler Martin on 4/24/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import UIKit
import Firebase

class TeamSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var ref: DatabaseReference?
    var refAvailableGames: DatabaseReference?
    
    var userID: String?
    var currentUID: String?
    var gameCode: String?
    var gameID: String?

    @IBOutlet weak var bluePlayerCount: UILabel!
    @IBOutlet weak var bluePlayers: UITableView!
    @IBOutlet weak var redPlayerCount: UILabel!
    @IBOutlet weak var redPlayers: UITableView!
    @IBOutlet weak var blueJoinBtn: UIButton!
    @IBOutlet weak var redJoinBtn: UIButton!
    @IBOutlet weak var startGameBtn: UIButton!
    @IBOutlet weak var resetTeamsBtn: UIButton!
    @IBOutlet weak var gameCodeField: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var gameCodeLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var redLabel: UILabel!
    
    @IBAction func joinBlue(_ sender: Any) {
        joinTeam(team: "blue")
    }
    
    @IBAction func joinRed(_ sender: Any) {
        joinTeam(team: "red")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGame" {
            if let destinationVC = segue.destination as? GameViewController {
                //destinationVC.game = GameManager.getGame(gameID: AvailableGameManager.getGame(gameCode: gameCode!).gameID)
                destinationVC.game = GameManager.getGame(gameID: gameID!)
            }
        }
    }
    
    func joinTeam(team: String) {
        AvailableGameManager.getGame(gameCode: gameCode!).updatePlayerString(userID: userID!, team: team)
        //AvailableGameManager.recordGameStatus(gameCode: gameCode!)
        
        let gameData = AvailableGameManager.getGame(gameCode: gameCode!).getGameData()
        
        refAvailableGames!.child(gameCode!).setValue(gameData, withCompletionBlock: { (error:Error?, dbRef:DatabaseReference?) in
            if let error = error {
                print("Data could not be saved: \(error).")
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
    
    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: "backToHome", sender: self)
    }
    
    @IBAction func startGame(_ sender: Any) {
        /*let game = AvailableGameManager.getGame(gameCode: gameCode!)
        GameManager.updateGame(gameID: game.gameID) { (result:String) in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showGame", sender: self)
            }
        }*/
        self.performSegue(withIdentifier: "showGame", sender: self)
    }
    
    @IBAction func resetTeams(_ sender: Any) {
        AvailableGameManager.getGame(gameCode: gameCode!).clearPlayers()
        AvailableGameManager.recordGameStatus(gameCode: gameCode!)
        self.updatePlayers()
        
        PlayerGameManager.removeGame(gameID: gameID!, userID: userID!)
        //PlayerGameManager.recordPlayerGameStatus(playerID: userID!, gameID: gameID!)
    }
    
    func createGame() {
        let availableGame = AvailableGameManager.getGame(gameCode: gameCode!)
        availableGame.setInitialRoles()
        let game = Game(gameID: availableGame.gameID, players: availableGame.getAllPlayers())
        game.createNewGame()
        GameManager.games.append(game)
        GameManager.recordGameStatus(gameID: game.gameID)
    }
    
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
    
    /*override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "darkTable.jpg")!)
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
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
