//
//  ViewController.swift
//  MemeME 1.0
//
//  Created by Ion Ceban on 3/18/21.
//

import UIKit
import Foundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    var memeImage: UIImage!
    

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var photoAlbumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    

   

    // pickAnImageFromLibrary Button
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        
        let albumPiccker = UIImagePickerController()
        albumPiccker.delegate = self
        albumPiccker.sourceType = .photoLibrary
        albumPiccker.allowsEditing = true
        self.present(albumPiccker, animated: true, completion: nil)
    }
        
       
    
    // pickAnImageFromCamera Button
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let cameraController = UIImagePickerController()
        cameraController.delegate = self
        cameraController.sourceType = .camera
        present(cameraController, animated: true, completion: nil)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    
    @IBAction func share(_ sender: Any) {
        memeImage = generateImage()
        let activity = UIActivityViewController(activityItems: [memeImage!], applicationActivities: nil)
        show(activity, sender: self)
        activity.completionWithItemsHandler = {(activity, completed, items, error) in
            if (completed){
                self.save()
                return
            }
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[.originalImage] as? UIImage{
                imagePickerView.image = image
            }
            dismiss(animated: true, completion: nil)
         }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           dismiss(animated: true, completion: nil)
        self.shareButton.isEnabled = false
        imagePickerView.image = nil
           }
    
    //Textfields
    func setTextField(_ textField: UITextField) {
        let memetextAttributes : [NSAttributedString.Key : Any] = [
            .strokeColor: UIColor.black,
            .foregroundColor: UIColor.white,
            .strikethroughColor: UIColor.white,
            .font: UIFont(name: "HelveticaNeue-CondensedBold", size: 40)!,
            .strokeWidth: -3.0
        ]
        textField.defaultTextAttributes = memetextAttributes
        textField.adjustsFontSizeToFitWidth = true
        textField.textAlignment = .center
        textField.allowsEditingTextAttributes = true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        
        
        subscribeToKeyboardNotifications()
      
    }
    
    
    
    func prepareView() {
        
        //Prepare text fields within image view
        
        self.topTextField.delegate = self
        self.bottomTextField.delegate = self
        
        self.setTextField(self.topTextField)
        self.setTextField(self.bottomTextField)
        
        //share button settings
        
        self.shareButton.isEnabled = true
    }
    
    
    func hideToolbars(_ hide: Bool) {
        topToolbar.isHidden = hide
        bottomToolbar.isHidden = hide
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    
    func generateImage() -> UIImage {
        
        // Hide toolbar and navbar
        
        hideToolbars(true)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        
        hideToolbars(false)

        return memedImage
    }
    

    
    
    // MARK: - Keyboard and Notifications
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()

    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    // MARK: - Functions related to keyboard presentation
    
    // Function called when keyboard must be shown and the screen must be moved up
    @objc func keyboardWillShow(_ notification:Notification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {

            
           return
    }
    
    // move up the picture
      if bottomTextField.isEditing {
    self.view.frame.origin.y = 0 - keyboardSize.height
      }}
    
        
    // Function called when screen must be moved down
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

    
   
    
    // Initializing a Meme object
    
    func save() {
        
            _ = Meme(topText: topTextField.text!,
                bottomText: bottomTextField.text!,
                originalImage:imagePickerView.image!,
                memedImage: generateImage())
                }
    
    }
    
