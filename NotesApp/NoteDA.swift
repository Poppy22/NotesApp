
import Foundation

class NoteDA: BaseDA {
    
    override init() {
        super.init()
        entityName = "Note"
    }
    
    func createNote() -> NoteModel {
        let note = super.create() as? NoteModel
        note?.set(title: "", detail: "", images: [], id: "", lastUpdate: 0)
        return note!
    }
    
    func getAllNotes() -> [NoteModel] {
        return super.fetchObjects(nil, sortDescriptors: nil) as! [NoteModel]
    }
    
    func deleteNote(_ note: NoteModel) {
        super.deleteObject(note)
        super.save()
    }
    
}
