//
//  TenantViewController.swift
//  Property Organizer
//
//  Created by Sean Pador on 6/25/17.
//  Copyright © 2017 Rodap. All rights reserved.
//

import UIKit
import os.log
import Foundation
import GoogleMobileAds

class TenantViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var monthRentTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var AdBanner: GADBannerView!
    
    //This value is passed by `TenantDetailViewController` in `prepare(for:sender:)`
    var tenant: Tenant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        phoneNumberTextField.delegate = self
        monthRentTextField.delegate = self
        
        notesTextView.delegate = self
        
        // Set up views if editing an existing property.
        if let tenant = tenant {
            navigationItem.title = tenant.name
            nameTextField.text = tenant.name
            phoneNumberTextField.text = tenant.phoneNumber
            monthRentTextField.text = String(tenant.monthRent)
            notesTextView.text = String(tenant.notes)
            photoImageView.image = tenant.photo
        }
        
        //request
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
        //set up ad
        AdBanner.adUnitID = "ca-app-pub-7522605235071115/8379618678"
        AdBanner.rootViewController = self
        AdBanner.delegate = self as? GADBannerViewDelegate
        AdBanner.load(request)
        
        // Enable the Save button only if the text fields are filled.
        updateSaveButtonState()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Prevent invalid character input, if text field is for month rent
        if (textField == monthRentTextField){
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters .isSuperset(of: characterSet)
        }
        else{
            return true
        }
    }
    //Hide keyboarded when user taps outside of it.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
     //MARK: UITextViewDelagate
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Disable the Save button while editing.
        //view.
        saveButton.isEnabled = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        saveButton.isEnabled = true
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        //navigationItem.title = textField.text
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddTenantMode = presentingViewController is UINavigationController
        
        if isPresentingInAddTenantMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The AddTenantViewController is not inside a navigation controller.")
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        let phoneNumber = phoneNumberTextField.text ?? ""
        let monthRent = monthRentTextField.text ?? ""
        let notes = notesTextView.text ?? ""
        let photo = photoImageView.image
        
        // Set the tenant to be passed to TenantTableViewController after the unwind segue.
        tenant = Tenant(name: name, phoneNumber: phoneNumber, notes: notes, monthRent: Int(monthRent)!, photo: photo)
    }
    

    @IBAction func selectImageFromPhotoStream(_ sender: UITapGestureRecognizer) {
        
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    //Prevents save button from being used if conditions arent met
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let nameText = nameTextField.text ?? ""
        let phoneText = phoneNumberTextField.text ?? ""
        let rentText = monthRentTextField.text ?? ""
        
        if(!nameText.isEmpty == true && !phoneText.isEmpty == true && !rentText.isEmpty){
            saveButton.isEnabled = true
        }
        else{
            saveButton.isEnabled = false
        }
    }
}
