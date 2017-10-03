//
//  AccountDA.swift
//  NotesApp
//
//  Created by Carmen Popa on 14/08/2017.
//  Copyright © 2017 Carmen Popa. All rights reserved.
//

import Foundation

class AccountDA: BaseDA {
    
    override init() {
        super.init()
        entityName = "Account"
    }
    
    func createAccount() -> Account {
        let account = super.create() as! Account
        account.set(name: "", id: "", token: "")
        return account
    }
    
    func getAccount() -> Account? {
        let accounts = super.fetchObjects(nil, sortDescriptors: nil) as? [Account]
        return accounts?.first
    }
    
    func deleteAccount(_ account: Account) {
        super.deleteObject(account)
        super.save()
    }

}
