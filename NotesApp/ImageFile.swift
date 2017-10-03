//
//  ImageFile.swift
//  NotesApp
//
//  Created by Carmen Popa on 10/08/2017.
//  Copyright © 2017 Carmen Popa. All rights reserved.
//

import CoreData

class ImageFile: NSManagedObject {
    
    @NSManaged private(set) var fileName: String?
    
    func set(fileName: String) {
        self.fileName = fileName
    }
}
