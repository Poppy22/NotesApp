//
//  AccountManager.swift
//  NotesApp
//
//  Created by Carmen Popa on 29/08/2017.
//  Copyright © 2017 Carmen Popa. All rights reserved.
//

import UIKit

private let Permissions = ["public_profile", "email", "user_friends"]

class AccountManager: NSObject {
    func requestLogin(done: @escaping ()->()) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: Permissions, from: nil) { (result, error) in
            if error == nil {
                let fbLoginResult = result
                if fbLoginResult?.grantedPermissions?.contains("email") != nil {
                    self.getUserData(done: done)
                }
            }
        }
    }
    
    func doLogout () {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        if let currentAccount = AccountDA().getAccount() {
            AccountDA().deleteAccount(currentAccount)
        }
    }
    
    func getUserData(done: @escaping ()->()) {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,name"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            let newAccount = AccountDA().createAccount()
            if error != nil {
                print("Error: \(String(describing: error))")
            } else {
                let name = (result as! [String: Any])["name"] as! String
                if let userID = FBSDKAccessToken.current().userID {
                    NoteAPI().requestAuthentication(userID: userID, success: { (token) in
                        newAccount.set(name: name, id: userID, token: token)
                        AccountDA().save()
                        done()
                    }, failure: { (error) in
                        print(error)
                    })
                }
            }
        })
    }
    
    func getProfileImage(id: String) -> NSURL {
        let imgURLString = "http://graph.facebook.com/" + id + "/picture?type=large&width=80&height=80"
        let imgURL = NSURL(string: imgURLString)
        return imgURL!
    }

}
