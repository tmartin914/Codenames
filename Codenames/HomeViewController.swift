//
//  HomeViewController.swift
//  Codenames
//
//  Created by Tyler Martin on 6/4/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var userID: String?
    var currentUID: String?
    var gameCode: String?
    var gameID: String?
    var goToTeamSelect = false
    var gamesLoaded = false
    
    @IBOutlet weak var newGameBtn: UIButton!
    @IBOutlet weak var gameCodeField: UITextField!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var notStartedCollectionView: UICollectionView!
    @IBOutlet weak var inProgressCollectionView: UICollectionView!
    @IBOutlet weak var completedCollectionView: UICollectionView!
    @IBOutlet weak var notStartedLabel: UILabel!
    @IBOutlet weak var inProgressLabel: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    
    @IBAction func logout(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "showLogin", sender: self)
        }
        catch let signOutError as NSError{
            print ("Error signing out: %@", signOutError)
        }
    }
    
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
    
    @IBAction func join(_ sender: Any) {
        if gameCodeField.text! == "" {
            let alert = UIAlertController(title: "Invalid Game Code", message: "No game codes entered!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else if gameCodeField.text!.count != 4 {
            let alert = UIAlertController(title: "Invalid Game Code", message: "Game code should be 4 characters", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else if AvailableGameManager.isGameCode(gameCode: gameCodeField.text!) {
            gameCode = gameCodeField.text!
            gameID = AvailableGameManager.getGame(gameCode: gameCode!).gameID
            self.performSegue(withIdentifier: "showTeamSelect", sender: self)
        } else {
            let alert = UIAlertController(title: "Invalid Game Code", message: "No game codes match \(gameCodeField.text!)!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTeamSelect" {
            if let destinationVC = segue.destination as? TeamSelectViewController {
                destinationVC.gameCode = gameCode!
                destinationVC.gameID = gameID!
            }
        } else if segue.identifier == "showGame" {
            if let destinationVC = segue.destination as? GameViewController {
                destinationVC.game = GameManager.getGame(gameID: gameID!)
            }
        }
    }
    
    func updateGames() {
        notStartedCollectionView.reloadData()
        inProgressCollectionView.reloadData()
        completedCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        goToTeamSelect = false
        AvailableGameManager.watchGames(){ (result:String) in
            DispatchQueue.main.async {
                self.updateGames();
                if self.goToTeamSelect {
                    self.performSegue(withIdentifier: "showTeamSelect", sender: self)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "darkTable.jpg")!)
        
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var status = GameStatus.notStarted
        if collectionView == notStartedCollectionView {
            status = .notStarted
        } else if collectionView == inProgressCollectionView {
            status = .inProgress
        } else if collectionView == completedCollectionView {
            status = .completed
        }
        
        let game = PlayerGameManager.getGameByType(status: status, index: indexPath.item)
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: collectionView.frame.height)
    }
    
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
