//
//  NoteManager.swift
//  NotesApp
//
//  Created by Carmen Popa on 29/08/2017.
//  Copyright © 2017 Carmen Popa. All rights reserved.
//

import UIKit

class NoteManager: NSObject {
    
    func mergeNotes(tableDataAPI: [[String: AnyObject]], tableData: [NoteModel]) -> [NoteModel] {
        var finalNotesArray = [NoteModel]()
        finalNotesArray = tableData
        for noteAPI in tableDataAPI {
            var found = false
            for localNote in tableData {
                if noteAPI["id"] as! String == localNote.id {
                    found = true
                    if noteAPI["lastUpdate"] as! Int64 > localNote.lastUpdate {
                        let note = NoteDA().createNote()
                        note.set(title: noteAPI["id"] as! String, detail: noteAPI["content"] as! String, images: [], id: noteAPI["id"] as! String, lastUpdate: noteAPI["lastUpdate"] as! Int64)
                        finalNotesArray.append(note)
                    }
                }
            }
            if found == false {
                let note = NoteDA().createNote()
                note.set(title: noteAPI["title"] as! String, detail: noteAPI["content"] as! String, images: [], id: noteAPI["id"] as! String, lastUpdate: noteAPI["lastUpdate"] as! Int64)
                finalNotesArray.append(note)
            }
        }
        return (finalNotesArray)
    }

    func deleteNote(currentAccount: Account, lastUpdated: Int64, id: String,
                    done: @escaping ()-> () ) {
        NoteAPI().requestDeleteNote(token: currentAccount.token, lastUpdated: lastUpdated, id: id,
                                    success: {
                                        done()
                                    },
                                    failure: { (error) in
                                        print(error)
                                        })
    }
    
    func updateNote(collectionData: [ImageFile], note:NoteModel, title:String, detail: String) {
        let imageSet = NSSet(array: collectionData)
        let noteID: String
        if note.id.isEmpty {
            noteID = UUID().uuidString
        } else {
            noteID = (note.id)!
        }
        let seconds = Int64(Date().timeIntervalSince1970)
        note.set(title: title, detail: detail, images: imageSet, id: noteID, lastUpdate: seconds)
        if note.title?.isEmpty == true && note.detail?.isEmpty == true && imageSet.count == 0 {
            NoteDA().rollback()
            NoteDA().deleteNote(note)
        } else {
            if let currentAccount = AccountDA().getAccount() {
                NoteAPI().requestUpdateNote(token: currentAccount.token!, note: note,
                                            success: { NoteDA().save() },
                                            failure: { (error) in
                                                print(error)
                })
            } else {
                NoteDA().save()
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
}
