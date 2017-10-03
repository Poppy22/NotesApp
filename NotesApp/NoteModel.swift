//
//  Note.swift
//  NotesApp
//
//  Created by Carmen Popa on 28/07/2017.
//  Copyright © 2017 Carmen Popa. All rights reserved.
//

import CoreData

class NoteModel: NSManagedObject {
    
     @NSManaged private(set) var title: String?
     @NSManaged private(set) var detail: String?
     @NSManaged private(set) var images: NSSet
     @NSManaged private(set) var id: String!
     @NSManaged private(set) var lastUpdate: Int64
    
    func set(title: String, detail: String, images: NSSet, id: String, lastUpdate: Int64)
    {
        self.title = title
        self.detail = detail
        self.images = images
        self.id = id
        self.lastUpdate = lastUpdate
    }
}
