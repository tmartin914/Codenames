//
//  LoginViewController.swift
//  Codenames
//
//  Created by Tyler Martin on 4/24/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import UIKit
import Firebase
import os.log

/// Login view controller class
@available(iOS 14.0, *)
class LoginViewController: UIViewController {
    
    /// Logger
    private let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: LoginViewController.self)
    )
    
    /// Login username field
    @IBOutlet weak var loginUsername: UITextField!
    
    /// Login password field
    @IBOutlet weak var loginPassword: UITextField!
    
    /// New username field
    @IBOutlet weak var newUsername: UITextField!
    
    /// New password field
    @IBOutlet weak var newPassword: UITextField!
    
    /// Name label
    @IBOutlet weak var nameLabel: UILabel!
    
    /// Login button
    @IBOutlet weak var loginBtn: UIButton!
    
    /// New user button
    @IBOutlet weak var newUserBtn: UIButton!
    
    /// Login
    @IBAction func login(_ sender: Any) {
        // TODO: update this to be an actual email on signup
        let loginEmail = loginUsername.text! + "@aol.com"
        Auth.auth().signIn(withEmail: loginEmail, password: loginPassword.text!){ (user, error) in
            if error == nil{
                self.logger.info("Successful login as \(self.loginUsername.text!)")
                self.performSegue(withIdentifier: SegueConstants.SHOW_HOME_SEGUE, sender: self)
            }
            else{
                self.logger.error("Invalid credentials for user: \(self.loginUsername.text!)")
                let alertContoller = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertContoller.addAction(defaultAction)
                self.present(alertContoller, animated: true, completion: nil)
            }
        }
    }
    
    /// Create new user
    @IBAction func createNewUser(_ sender: Any) {
        // TODO: update this to be an actual email on signup
        let newEmail = newUsername.text! + "@aol.com"
        Auth.auth().createUser(withEmail: newEmail, password: newPassword.text!){ [self] (user, error) in
            if error == nil{
                self.logger.info("Successfully created user: \(self.newUsername.text!)")
                // TODO: i dont think this works - firebase is broken
                let currentUser = Auth.auth().currentUser!
                let changeRequest = currentUser.createProfileChangeRequest()
                changeRequest.displayName = self.newUsername.text!
                changeRequest.commitChanges(completion: { (error) in
                    print(error.debugDescription)
                })
                
                self.performSegue(withIdentifier: SegueConstants.SHOW_HOME_SEGUE, sender: self)
            }
            else{
                self.logger.error("Unable to create new user: \(self.newUsername.text!)")
                let alertContoller = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertContoller.addAction(defaultAction)
                self.present(alertContoller, animated: true, completion: nil)
            }
        }
    }
    
    /// On view loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: ResourceConstants.DARK_TABLE_IMAGE)!)
        
        nameLabel.textColor = UIColor(red: 245, green: 222, blue: 179)
        
        let buttons = [loginBtn, newUserBtn]
        for button in buttons {
            button!.layer.cornerRadius = 5
            button!.layer.borderWidth = 1
            button!.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    /// On view appearing
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser != nil{
            PlayerGameManager.loadGames(userID: (Auth.auth().currentUser!.email?.components(separatedBy: "@")[0])! ) { (result:String) in
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: SegueConstants.SHOW_HOME_SEGUE, sender: nil)
                }
            }
        }
        
        loginPassword.isSecureTextEntry = true
        newPassword.isSecureTextEntry = true
    }
}
