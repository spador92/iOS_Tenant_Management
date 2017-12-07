//
//  Tenant.swift
//  Tenant Management
//
//  Created by Sean Pador on 6/26/17.
//  Copyright © 2017 Rodap. All rights reserved.
//

import UIKit
import os.log


class Tenant: NSObject, NSCoding {
    
    //Properties
    var name: String
    var phoneNumber: String
    var notes: String
    var monthRent: Int
    var currentDue: Int
    var photo: UIImage?
    
    //Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("tenants")
    
    //MARK: Types
    struct TenantKey {
        static let name = "name"
        static let phoneNumber = "phoneNumber"
        static let notes = "notes"
        static let monthRent = "monthDue"
        static let currentDue = "currentDue"
        static let photo = "photo"
    }
    
    //MARK: Initialization
    init?(name: String, phoneNumber: String = "", notes: String = "", monthRent: Int = 0, currentDue: Int = 0, photo: UIImage?) {
        
        // The address must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.phoneNumber = phoneNumber
        self.notes = notes
        self.monthRent = monthRent
        self.currentDue = currentDue
        self.photo = photo
    }
    
    //MARK: NSCoding
    func Currency(amount: Int) -> String{
        //When amount is positive or zero
        if(amount >= 0){
            return " $" + String(amount)
        }
        else {
            return "-$" + String(abs(amount))
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: TenantKey.name)
        aCoder.encode(phoneNumber, forKey: TenantKey.phoneNumber)
        aCoder.encode(notes, forKey: TenantKey.notes)
        aCoder.encode(monthRent, forKey: TenantKey.monthRent)
        aCoder.encode(currentDue, forKey: TenantKey.currentDue)
        aCoder.encode(photo, forKey: TenantKey.photo)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The address is required. If we cannot decode a address string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: TenantKey.name) as? String else {
            os_log("Unable to decode the name for a Tenant object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let phoneNumber = aDecoder.decodeObject(forKey: TenantKey.phoneNumber) as? String
        //let notes = aDecoder.decodeObject(forKey: TenantKey.notes) as? String
        let monthRent = aDecoder.decodeInteger(forKey: TenantKey.monthRent)
        let currentDue = aDecoder.decodeInteger(forKey: TenantKey.currentDue)
        
        // Because photo is an optional property of Property, just use conditional cast.
        let photo = aDecoder.decodeObject(forKey: TenantKey.photo) as? UIImage
        
        // Must call designated initializer.
        self.init(name: name, phoneNumber: phoneNumber!, /*notes: notes,*/monthRent: monthRent, currentDue: currentDue, photo: photo)
    }
}
