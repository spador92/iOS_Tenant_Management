import UIKit
import os.log
import Foundation
import GoogleMobileAds

class TenantPayViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GADBannerViewDelegate{
    
    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var monthRentLabel: UILabel!
    @IBOutlet weak var currentDueLabel: UILabel!
    @IBOutlet weak var newDueLabel: UILabel!
    var newDue = 0
    
    @IBOutlet weak var deductLabel: UILabel!
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var payAmountTextField: UITextField!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    
    @IBOutlet weak var AdBanner: GADBannerView!
    
    var tenant: Tenant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up views if editing an existing property.
        if let tenant = tenant {
            nameLabel.text = tenant.name
            monthRentLabel.text = tenant.Currency(amount: tenant.monthRent)
            currentDueLabel.text = tenant.Currency(amount: tenant.currentDue)
            newDue = tenant.currentDue
        }
        
        plusButton.isEnabled = false
        plusButton.backgroundColor = #colorLiteral(red: 0.6131092457, green: 0.609602114, blue: 0.6245315924, alpha: 1)
        saveButton.isEnabled = false
        
        self.payAmountTextField.delegate = self
        
        self.AdBanner.delegate = self
        
        initAdBanner()
        updatePayButtonState()
    }
    
    
    // MARK: -  ADMOB BANNER
    func initAdBanner() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            // iPhone
            AdBanner.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
            AdBanner.frame = CGRect(x: 0, y: view.frame.size.height, width: 320, height: 50)
        }
        else  {
            // iPad
            AdBanner.adSize =  GADAdSizeFromCGSize(CGSize(width: 468, height: 60))
            AdBanner.frame = CGRect(x: 0, y: view.frame.size.height, width: 468, height: 60)
        }
     
     //request
     let request = GADRequest()
     request.testDevices = [kGADSimulatorID]
     
     //set up ad
     AdBanner.adUnitID = "ca-app-pub-7522605235071115/8379618678"
     AdBanner.rootViewController = self
     AdBanner.delegate = self as? GADBannerViewDelegate
     AdBanner.load(request)
    }
    
    //Closes keyboard when user touches outside of it
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
        
        updatePayButtonState()
    }
    
    //MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters .isSuperset(of: characterSet)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        payButton.isEnabled = false
        payButton.setTitleColor(#colorLiteral(red: 0.6131092457, green: 0.609602114, blue: 0.6245315924, alpha: 1), for: .normal)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updatePayButtonState()
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
        guard let button = sender as? UIBarButtonItem, button === self.saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
            
            let currentDue = newDue
            
            // Set the tenant to be passed to TenantDetailViewController after the unwind segue.
        tenant = Tenant(name: (tenant?.name)!, phoneNumber: tenant!.phoneNumber, notes: tenant!.notes, monthRent: tenant!.monthRent, currentDue: currentDue, photo: tenant?.photo)
    }
    
    
    //Add monthly rent to due when button is pressed
    @IBAction func NextMonthButton(_ sender: Any) {
        let result = newDue - (tenant?.monthRent)!
        
        deductLabel.text = "-   " + (tenant?.Currency(amount: (tenant?.monthRent)!))!
        newDueLabel.text = tenant?.Currency(amount: newDue)
        resultLabel.text = tenant?.Currency(amount: result)
        newDue = result
        
        //Enable save button
        saveButton.isEnabled = true
    }
    
    //MARK: Actions
    
    @IBAction func payButton(_ sender: Any) {
        
        let amount = Int(payAmountTextField.text!)
        var result = 0
        
        //Check whether change is positive or negative
        if(plusButton.isEnabled == false){
            result = newDue + amount!
        }
        else{
            result = newDue - amount!
        }
        
        //output
        newDueLabel.text = tenant?.Currency(amount: newDue)
        deductLabel.text = tenant?.Currency(amount: amount!)
        
        if(plusButton.isEnabled == false){
            deductLabel.text = "+   " + (tenant?.Currency(amount: amount!))!
        }
        else{
            deductLabel.text = "-   " + (tenant?.Currency(amount: amount!))!
        }
        resultLabel.text = tenant?.Currency(amount: result)
        newDue = result
        
        //Enable save button
        saveButton.isEnabled = true
    }
    
    //Indicate transaction is positive when button is pressed
    @IBAction func plusButton(_ sender: Any) {
        plusButton.isEnabled = false
        minusButton.isEnabled = true
        plusButton.backgroundColor = #colorLiteral(red: 0.6131092457, green: 0.609602114, blue: 0.6245315924, alpha: 1)
        minusButton.backgroundColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
    }
    
    //Indicate transaction is negative when button is pressed
    @IBAction func minusButton(_ sender: Any) {
        minusButton.isEnabled = false
        plusButton.isEnabled = true
        minusButton.backgroundColor = #colorLiteral(red: 0.6131092457, green: 0.609602114, blue: 0.6245315924, alpha: 1)
        plusButton.backgroundColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
    }
    
    //Prevents save button from being used if conditions arent met
    private func updatePayButtonState() {
        let payText = payAmountTextField.text ?? ""
        
        // Enable the Save button if the text field is filled.
        if(!payText.isEmpty == true){
            payButton.isEnabled = true
            payButton.setTitleColor(#colorLiteral(red: 0.5319960509, green: 0.8331765197, blue: 0.1371351244, alpha: 1), for: .normal)
        }
        // Disable the Save button if the text field is empty.
        else{
            payButton.isEnabled = false
            payButton.setTitleColor(#colorLiteral(red: 0.6131092457, green: 0.609602114, blue: 0.6245315924, alpha: 1), for: .normal)
        }
    }
}
