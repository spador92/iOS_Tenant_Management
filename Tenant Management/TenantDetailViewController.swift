//
//  tenantDetailViewController.swift
//  Tenant Management
//
//  Created by Sean Pador on 7/1/17.
//  Copyright © 2017 Rodap. All rights reserved.
//

import UIKit
import os.log
import Foundation
import GoogleMobileAds

class TenantDetailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var monthlyRentLabel: UILabel!
    @IBOutlet weak var currentDueLabel: UILabel!
    
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var AdBanner: GADBannerView!
    /*
     This value is either passed by `TenantTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new Tenant.
     */
    var tenant: Tenant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        //nameTextField.delegate = self
        
        // Set up views if editing an existing property.
        if let tenant = tenant {
            navigationItem.title = tenant.name
            phoneNumberLabel.text = "#  " + tenant.phoneNumber
            monthlyRentLabel.text = "Rent:  " + tenant.Currency(amount: tenant.monthRent)
            currentDueLabel.text = "Due:   " + tenant.Currency(amount: tenant.currentDue)
            notesTextView.text = tenant.notes
            photoImageView.image = tenant.photo
            
        }
        
        //request ad
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
        //set up ad
        AdBanner.adUnitID = "ca-app-pub-7522605235071115/8379618678"
        AdBanner.rootViewController = self
        AdBanner.delegate = self as? GADBannerViewDelegate
        AdBanner.load(request)
        
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
        //updateSaveButtonState()
        navigationItem.title = textField.text
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
        
        switch(segue.identifier ?? "") {
            
            case "Pay":
                guard let tenantPayViewController = segue.destination as? TenantPayViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
                }
        
                let selectedTenant = tenant
                tenantPayViewController.tenant = selectedTenant
        
            case "MakeEdit":
                guard let tenantDetailViewController = segue.destination as? TenantViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
        
                let selectedTenant = tenant
                tenantDetailViewController.tenant = selectedTenant
        default:
           /* // Set the tenant to be passed to TenantDetailViewController after the unwind segue.
            tenant = Tenant(name: (tenant?.name)!, phoneNumber: tenant!.phoneNumber, monthRent: tenant!.monthRent, currentDue: (tenant?.currentDue)!, photo: tenant?.photo)*/
            break
        }
        
    }
    
}
