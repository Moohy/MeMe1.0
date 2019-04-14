//
//  ViewController.swift
//  MeMe
//
//  Created by Mohammed on 11/4/19.
//  Copyright © 2019 Mohammed. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    struct Meme{
        let topText: String
        let bottomText: String
        let originalImage: UIImage
        let memedImage: UIImage
    }

    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextField(topTextField, text: "TOP")
        configureTextField(bottomTextField, text: "BOTTOM")
 
        shareButton.isEnabled = false


    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func configureTextField(_ textField: UITextField, text: String) {
        textField.text = text
        textField.delegate = self
        textField.defaultTextAttributes = [
            .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            .strokeColor: UIColor.black,
            .foregroundColor: UIColor.white,
            .strokeWidth: -8.0
        ]
        textField.textAlignment = .center
    }
    
    @IBAction func pickAnImageFromAlbum(){
        pickAnImage(.photoLibrary)
    }
    
    @IBAction func takeAnImageFromCamera(){
       pickAnImage(.camera)
    }
    
    func pickAnImage(_ source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            imagePickerView.contentMode = .scaleAspectFit
        }
        shareButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),  name: UIResponder.keyboardWillShowNotification, object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),  name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if (bottomTextField.isFirstResponder){ //or bottomTextField.isFirstResponder
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self,  name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.removeObserver(self,  name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
 
        return textField.text = ""

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return textField.resignFirstResponder()
        
    }
    
    func save() {
        
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: self.generateMemedImage())
    }
    
    func generateMemedImage() -> UIImage {
        
        self.toolBar.isHidden = true
        self.navBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.toolBar.isHidden = false
        self.navBar.isHidden = false
        
        return memedImage
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let memeGenerate = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memeGenerate], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
        controller.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }

}

