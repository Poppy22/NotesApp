//
//  LoginViewController.swift
//  NotesApp
//
//  Created by Carmen Popa on 31/07/2017.
//  Copyright © 2017 Carmen Popa. All rights reserved.
//

import UIKit
import SDWebImage

private let Permissions = ["public_profile", "email", "user_friends"]
private let ButtonIsLoggedInState = "LOG OUT"
private let ButtonIsLoggedOutState = "CONNECT WITH FACEBOOK"
private let NotLoggedIn = "You're not logged in"
private let IsLoggedInMessage = "You're awesome!"
private let IsLoggedOutMessage = "You're missing all the fun!"

class LoginViewController: BaseController {

    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var loginButton: UIButton!
    
    var isLoggedIn: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.titleLabel?.textAlignment = NSTextAlignment.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let currentAccount = AccountDA().getAccount() {
            setLoginState(currentAccount: currentAccount)
        } else {
            setLogoutState()
        }
    }
    
    func setLoginState(currentAccount: Account) {
        let imageURL = AccountManager().getProfileImage(id: currentAccount.id)
        self.profileImageView.sd_setImage(with: imageURL as URL, completed: nil)
        self.nameLabel.text = currentAccount.name
        self.isLoggedIn = true
        self.messageLabel.text = IsLoggedInMessage
        self.loginButton.setTitle(ButtonIsLoggedInState, for: .normal)
    }
    
    func setLogoutState() {
        self.isLoggedIn = false
        self.loginButton.setTitle(ButtonIsLoggedOutState, for: .normal)
        self.nameLabel.text = NotLoggedIn
        self.messageLabel.text = IsLoggedOutMessage
        self.profileImageView.image = #imageLiteral(resourceName: "ph_profile")
    }
    
    @IBAction func onTapFbLogin(_ sender: Any) {
        if isLoggedIn == false {
            AccountManager().requestLogin(done: { 
                if let currentAccount = AccountDA().getAccount() {
                    self.setLoginState(currentAccount: currentAccount)
                }
            })
        } else {
            AccountManager().doLogout()
            setLogoutState()
        }
    }
    
}
