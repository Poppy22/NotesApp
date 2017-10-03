//
//  ImageFileDA.swift
//  NotesApp
//
//  Created by Carmen Popa on 11/08/2017.
//  Copyright © 2017 Carmen Popa. All rights reserved.
//

import Foundation

class ImageFileDA: BaseDA {
    override init() {
        super.init()
        entityName = "ImageFile"
    }
    
    func createImageFile() -> ImageFile {
        let imageFile = super.create() as! ImageFile
        imageFile.set(fileName: "")
        return imageFile
    }
    
    func deleteImageFile(_ imageFile: ImageFile) {
        super.deleteObject(imageFile)
        super.save()
    }
}
