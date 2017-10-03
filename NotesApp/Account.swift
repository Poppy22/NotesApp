//
//  Account.swift
//  NotesApp
//
//  Created by Carmen Popa on 14/08/2017.
//  Copyright © 2017 Carmen Popa. All rights reserved.
//

import CoreData
// FEEDBACK (AV): * You shouldn't save user data in core data usually

class Account: NSManagedObject {
    
    @NSManaged private(set) var name: String!
    @NSManaged private(set) var id: String!
    @NSManaged private(set) var token: String!
    
    func set(name: String, id: String, token: String) {
        self.name = name
        self.id = id
        self.token = token
    }
}
