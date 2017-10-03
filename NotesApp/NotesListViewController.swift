//
//  NotesListViewController.swift
//  NotesApp
//
//  Created by Carmen Popa on 27/07/2017.
//  Copyright © 2017 Carmen Popa. All rights reserved.
//

import UIKit

private let SegueToNote = "segueToNote"
private let SegueToLogin = "segueToLogin"
private let NoteIdentifier = "notecell"

class NotesListViewController: BaseController, UITableViewDelegate, UITableViewDataSource, NoteCellDelegate {
    @IBOutlet private weak var noteTableView: UITableView!
    @IBOutlet private weak var addNoteButton: UIButton!
    @IBOutlet private weak var emptyNoteListView: UIView!
    
    @IBOutlet private weak var rightBarButton: UIBarButtonItem!
    @IBOutlet private weak var leftBarButtton: UIBarButtonItem!
    
    var tableData = [NoteModel]()
    var notesAPI = [NoteModel]()
    var editModeOn = false
    var selectedNotesIndex = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTableView.rowHeight = UITableViewAutomaticDimension
        noteTableView.estimatedRowHeight = 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayNotes()
    }
    
    private func displayNotes() {
        
        self.tableData = NoteDA().getAllNotes()
        if let currentAccount = AccountDA().getAccount() {
            NoteAPI().requestAllNotes(token: currentAccount.token, success: { (tableDataAPI) in
                self.tableData = NoteManager().mergeNotes(tableDataAPI: tableDataAPI, tableData: self.tableData)
                self.loadMainScreen()
            },
            failure: { (error) in
                print (error)
            })
        } else {
            loadMainScreen()
        }
    }
    
    private func loadMainScreen() {
        editModeOn = false
        self.leftBarButtton.image = nil
        rightBarButton.image = #imageLiteral(resourceName: "ic_nav_profile")
        leftBarButtton.image = nil
        self.title = "myNotes"
        self.tableData = self.tableData.sorted(by: { $0.lastUpdate > $1.lastUpdate })
        self.noteTableView.reloadData()
        self.emptyNoteListView.isHidden = self.tableData.count != 0
        self.noteTableView.isHidden = self.tableData.count == 0
    }
    
    func deleteNote (indexPath: Int) {
        NoteDA().deleteNote(self.tableData[indexPath])
        self.tableData.remove(at: indexPath)
        loadMainScreen()
    }
    
    func onCellLongTap(longPressgestureRecognizer: UILongPressGestureRecognizer, cell: UITableViewCell) {
        if longPressgestureRecognizer.state == UIGestureRecognizerState.began {
            
            if let indexPath = noteTableView.indexPath(for: cell) {
                rightBarButton.image = #imageLiteral(resourceName: "ic_trash")
                leftBarButtton.image = #imageLiteral(resourceName: "ic_close_popup")
                editModeOn = true
                selectedNotesIndex.append(indexPath.row)
                noteTableView.reloadData()
            }
        }
    }
    
    func deleteSelectedNotes(alert: UIAlertAction) {
        selectedNotesIndex.sort()
        selectedNotesIndex.reverse()
        
        for noteIndex in selectedNotesIndex {
            let note = tableData[noteIndex]
            let index = self.selectedNotesIndex.index(of: noteIndex)
            selectedNotesIndex.remove(at: index!)
            if let currentAccount = AccountDA().getAccount() {
                NoteManager().deleteNote(currentAccount: currentAccount, lastUpdated: note.lastUpdate, id: note.id, done: {
                    self.deleteNote(indexPath: noteIndex)
                })
            } else {
               deleteNote(indexPath: noteIndex)
            }
        }
    }

    //Table View Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteIdentifier, for: indexPath as IndexPath) as! NoteCell
        let note = tableData[indexPath.row]
        cell.delegate = self
        cell.loadData(note: note, editModeOn: editModeOn, isSelected: selectedNotesIndex.contains(indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            if let currentAccount = AccountDA().getAccount() {
                let currentNote = self.tableData[indexPath.row]
                NoteManager().deleteNote(currentAccount: currentAccount, lastUpdated: currentNote.lastUpdate, id: currentNote.id, done: {
                    self.deleteNote(indexPath: indexPath.row)
                })
            } else {
                deleteNote(indexPath: indexPath.row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if editModeOn == false {
            let note = tableData[indexPath.row]
            self.performSegue(withIdentifier: SegueToNote, sender: note)
        } else {
            if selectedNotesIndex.contains(indexPath.row) {
                let index = selectedNotesIndex.index(of: indexPath.row)
                selectedNotesIndex.remove(at: index!)
            } else {
                selectedNotesIndex.insert(indexPath.row, at: 0)
            }
            noteTableView.reloadData()
            self.title = "\(selectedNotesIndex.count)"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SegueToNote) {
            if sender is NoteModel {
                if let detailsController = segue.destination as? NoteDetailsViewController {
                    detailsController.note = (sender as? NoteModel)!
                }
            }
        }
    }

    @IBAction func onAddTapped() {
        if editModeOn == false {
            let newNote = NoteDA().createNote()
            self.performSegue(withIdentifier: SegueToNote, sender: newNote)
        }
    }
    
    @IBAction func onExitLongPress(_ sender: Any) {
        loadMainScreen()
    }
    
    @IBAction func onTapRightButton(_ sender: Any) {
        if editModeOn == false {
            self.performSegue(withIdentifier: SegueToLogin, sender: rightBarButton)
        } else {
            let alertController = UIAlertController(title: nil, message: "Are you sure you want to permanently delete these notes?", preferredStyle: .alert)
            let defaultActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            let defaultActionDelete = UIAlertAction(title: "Delete", style: .default, handler: deleteSelectedNotes)
            alertController.addAction(defaultActionCancel)
            alertController.addAction(defaultActionDelete)
            present(alertController, animated: true, completion: nil)
        }
    }
}
