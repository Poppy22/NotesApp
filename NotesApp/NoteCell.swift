//
//  NotesTableViewCell.swift
//  NotesApp
//
//  Created by Carmen Popa on 28/07/2017.
//  Copyright © 2017 Carmen Popa. All rights reserved.
//

import UIKit

protocol NoteCellDelegate {
    func onCellLongTap(longPressgestureRecognizer: UILongPressGestureRecognizer, cell: UITableViewCell)
}

class NoteCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var descriptionLabel: UILabel?
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var statusImageView: UIImageView!
    
    @IBOutlet private weak var topTitleConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topDescriptionConstraint: NSLayoutConstraint!
    
    var delegate: NoteCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setGestureRecognizer()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func loadData(note: NoteModel, editModeOn: Bool, isSelected: Bool) {
        titleLabel?.text = note.title
        descriptionLabel?.text = note.detail
        titleHeightConstraint.constant = 25
        topTitleConstraint.constant = 12
        topDescriptionConstraint.constant = 12
        
        if titleLabel?.text?.characters.count == 0 {
            titleHeightConstraint.constant = 0
            topTitleConstraint.constant = 0
            if note.detail?.characters.count == 0 {
                if note.images.count != 0 {
                    descriptionLabel?.text = "Attachment only"
                }
            }
        } else {
            if descriptionLabel?.text?.characters.count == 0 {
                topDescriptionConstraint.constant = 0
            }
        }
        
        if note.images.count > 0 {
            iconImageView.image = #imageLiteral(resourceName: "ic_note_image")
        } else {
            iconImageView.image = #imageLiteral(resourceName: "ic_note_text")
        }
        
        if editModeOn == true {
            statusImageView.image = #imageLiteral(resourceName: "checkbox_off")
        } else {
            statusImageView.image = nil
        }
        
        if isSelected == true {
            statusImageView.image = #imageLiteral(resourceName: "checkbox_on")
        }
    }
    
    func setGestureRecognizer() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.delegate = self as UIGestureRecognizerDelegate
        self.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongPress(_ longPressgestureRecognizer: UILongPressGestureRecognizer) {
        delegate?.onCellLongTap(longPressgestureRecognizer: longPressgestureRecognizer, cell: self)
    }
    
}
