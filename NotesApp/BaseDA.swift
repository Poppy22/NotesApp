//
//  BaseDA.swift
//  NotesApp
//
//  Created by Andrei Vasilescu on 15/12/15.
//  Copyright © 2015 mready. All rights reserved.
//

import CoreData

class BaseDA {
    var defaultContext: NSManagedObjectContext!
    internal var entityName: String!
    
    init() {
        defaultContext = CoreDataManager.shared.managedObjectContext
    }
    
    func save() {
        commitDefaultMOC()
    }
    
    func rollback() {
        self.defaultContext.rollback()
    }
    
    func create() -> NSManagedObject {
        let createdObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: defaultContext)
        
        return createdObject
    }
    
    func deleteObject(_ object:NSManagedObject) {
        self.defaultContext.delete(object)
    }
    
    func commitDefaultMOC () -> Bool {
        do {
            try self.defaultContext.save()
            return true
        } catch _ {
            return false
        }
    }
    
    func isObjectExisting(_ object:NSManagedObject) -> Bool {
        return self.defaultContext.registeredObject(for: object.objectID) == nil
    }
    
    func deleteObjects(_ objects:[NSManagedObject]) {
        for object in objects {
            deleteObject(object)
        }
    }
    
    func fetchObjects(_ predicate:NSPredicate?, sortDescriptors:Array<NSSortDescriptor>?) -> [AnyObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        var results:[AnyObject]?
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: entityName, in: defaultContext)
        
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        do {
            results = try defaultContext.fetch(fetchRequest)
        } catch _ {
            NSLog("Failed to execute fetch request:\n entity:\(entityName)")
        }
        
        return results!
    }
}
