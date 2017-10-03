//
//  CollectionViewCell.swift
//  NotesApp
//
//  Created by Carmen Popa on 02/08/2017.
//  Copyright © 2017 Carmen Popa. All rights reserved.
//

import UIKit

protocol ImageCellDelegate{
    func deletePhoto(indexPath: IndexPath)
}

class ImageCell: UICollectionViewCell {
    
    @IBOutlet private weak var attachmentImageView: UIImageView!
    @IBOutlet private weak var deleteButton: UIButton!
    
    var delegate: ImageCellDelegate?
    var indexPath: IndexPath!
    
    func loadData(image: UIImage, editModeOn: Bool, indexPath: IndexPath) {
        attachmentImageView.image = image
        deleteButton.isHidden = !editModeOn
        self.indexPath = indexPath
    }

    @IBAction func onDeleteTappedPhoto(_ sender: Any) {
        delegate?.deletePhoto(indexPath: self.indexPath)
    }
}
