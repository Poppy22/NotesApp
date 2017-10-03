//
//  NoteDetailsViewController.swift
//  NotesApp
//
//  Created by Carmen Popa on 27/07/2017.
//  Copyright © 2017 Carmen Popa. All rights reserved.
//

import UIKit

class NoteDetailsViewController: BaseController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ImageCellDelegate {
    
    var note: NoteModel?
    var collectionData = [ImageFile]()
    
    var editModeOn = false
    var isKeyboardUp = false
    
    var keyboardHeight: CGFloat = 0.0
    let EmptyCollectionViewHeight = 0
    let DefaultCollectionViewHeight = 160

    @IBOutlet private weak var imageCollectionView: UICollectionView!
    @IBOutlet private weak var attachButton: UIBarButtonItem!
    
    @IBOutlet private weak var titleField: UITextField!
    @IBOutlet private weak var detailTextView: UITextView!
    @IBOutlet private weak var placeholderLabel: UILabel!
    
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeNotifications()
        loadNote()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeSettings()
    }
    
    //Dismiss keyboard when touching outside the text fields
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func initializeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    private func toggleImagesOn(isOn: Bool) {
        imageCollectionView.isHidden = !isOn
        if (isOn == true) {
            heightConstraint.constant = CGFloat(DefaultCollectionViewHeight)
        } else {
            heightConstraint.constant = CGFloat(EmptyCollectionViewHeight)
        }
    }
    
    private func loadNote() {
        
        if note?.detail?.characters.count == 0 || note?.detail == nil {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
            detailTextView.text = note?.detail
        }
        titleField.text = note?.title
        let imageArray = note?.images.allObjects as! [ImageFile]
        if imageArray.count != 0 {
            collectionData = imageArray
            imageCollectionView.reloadData()
        }
    }
    
    private func initializeSettings() {
        if titleField.text?.characters.count == 0 {
            titleField.becomeFirstResponder()
            titleField.attributedPlaceholder = NSAttributedString(string: titleField.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
        }
        
        detailTextView.delegate = self
        imageCollectionView.reloadData()
        self.toggleImagesOn(isOn: collectionData.count != 0)
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(NoteDetailsViewController.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.delegate = self as? UIGestureRecognizerDelegate
        imageCollectionView.addGestureRecognizer(longPressGesture)
        
    }

    private func saveNote() {
        NoteManager().updateNote(collectionData: collectionData, note: note!, title: titleField.text!, detail: detailTextView.text)
    }

    internal func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
    
    internal func textViewDidEndEditing(_ textView: UITextView) {
        if detailTextView.text.characters.count == 0 {
            placeholderLabel.isHidden = false
        }
    }
    
    func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        editModeOn = true
        attachButton.image = nil
        attachButton.title = "Cancel"
        imageCollectionView.reloadData()
    }
    
    internal func deletePhoto(indexPath: IndexPath) {
        let index = indexPath.row
        ImageFileDA().deleteImageFile(collectionData[index])
        collectionData.remove(at: index)
        imageCollectionView.reloadData()
        if collectionData.count == 0 {
            heightConstraint.constant = 0
            imageCollectionView.isHidden = true
            attachButton.image = nil
            attachButton.title = nil
        }
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
        if isKeyboardUp == false {
            bottomConstraint.constant += keyboardHeight
            isKeyboardUp = true
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if isKeyboardUp == true {
            bottomConstraint.constant -= keyboardHeight
            isKeyboardUp = false
        }
    }
    
    //Collection view delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath as IndexPath) as! ImageCell
        
        cell.delegate = self
        
        let fileName = collectionData[indexPath.row].fileName!
        let filePath = NoteManager().getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: filePath)
            let image = UIImage(data: imageData)
            cell.loadData(image: image!, editModeOn: editModeOn, indexPath: indexPath)
        } catch _ {
        }
        
        return cell
    }
    
    func addPhotoFromGallery(alert: UIAlertAction) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func addPhotoFromCamera(alert: UIAlertAction) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let data = UIImagePNGRepresentation(pickedImage)

            let filename = "\(String(Date().timeIntervalSince1970)).png"
            let filePath = NoteManager().getDocumentsDirectory().appendingPathComponent(filename)
            try? data?.write(to: filePath)
        
            let imgFile = ImageFileDA().createImageFile()
            imgFile.set(fileName: filename)
            
            collectionData.append(imgFile)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func setPopup () {
        let alertController = UIAlertController(title: nil, message: "Attach image", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Take picture", style: .default, handler: addPhotoFromCamera)
        let gallery = UIAlertAction(title: "Choose from gallery", style: .default, handler: addPhotoFromGallery)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(camera)
        alertController.addAction(gallery)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onPressedReturnKeyTitleTextField(_ sender: Any) {
        detailTextView.becomeFirstResponder()
        titleField.resignFirstResponder()
    }
    
    @IBAction func onGoBack(_ sender: Any) {
        saveNote()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAttachImage(_ sender: Any) {
        if editModeOn == false {
            setPopup()
        } else {
            editModeOn = false
            imageCollectionView.reloadData()
            attachButton.title = nil
            attachButton.image = #imageLiteral(resourceName: "ic_nav_attach")
        }
    }
}
