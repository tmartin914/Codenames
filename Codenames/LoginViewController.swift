//
//  LoginViewController.swift
//  Codenames
//
//  Created by Tyler Martin on 4/24/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var loginUsername: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    @IBOutlet weak var newUsername: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var newUserBtn: UIButton!
    
    @IBAction func login(_ sender: Any) {
        let loginEmail = loginUsername.text! + "@aol.com"
        Auth.auth().signIn(withEmail: loginEmail, password: loginPassword.text!){ (user, error) in
            if error == nil{
                self.performSegue(withIdentifier: "showHome", sender: self)
            }
            else{
                let alertContoller = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertContoller.addAction(defaultAction)
                self.present(alertContoller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func createNewUser(_ sender: Any) {
        let newEmail = newUsername.text! + "@aol.com"
        Auth.auth().createUser(withEmail: newEmail, password: newPassword.text!){ (user, error) in
            if error == nil{
                // TODO: i dont think this works - firebase is broken
                let currentUser = Auth.auth().currentUser!
                let changeRequest = currentUser.createProfileChangeRequest()
                changeRequest.displayName = self.newUsername.text!
                changeRequest.commitChanges(completion: { (error) in
                    print(error.debugDescription)
                })
                
                self.performSegue(withIdentifier: "showHome", sender: self)
            }
            else{
                let alertContoller = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertContoller.addAction(defaultAction)
                self.present(alertContoller, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "darkTable.jpg")!)
        
        nameLabel.textColor = UIColor(red: 245, green: 222, blue: 179)
        
        let buttons = [loginBtn, newUserBtn]
        for button in buttons {
            button!.layer.cornerRadius = 5
            button!.layer.borderWidth = 1
            button!.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser != nil{
            PlayerGameManager.loadGames(userID: (Auth.auth().currentUser!.email?.components(separatedBy: "@")[0])! ) { (result:String) in
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showHome", sender: nil)
                }
            }
        }
        
        loginPassword.isSecureTextEntry = true
        newPassword.isSecureTextEntry = true
    }
}
