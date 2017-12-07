//
//  TenantTableViewController.swift
//  Tenant Management
//
//  Created by Sean Pador on 6/26/17.
//  Copyright © 2017 Rodap. All rights reserved.
//

import UIKit
import os.log

class TenantTableViewController: UITableViewController {
    
    //MARK: Properties
    //Create array of Tenants
    var tenants = [Tenant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 0.5319960509, green: 0.8331765197, blue: 0.1371351244, alpha: 1)
        
        // Load any saved meals, otherwise load sample data.
        if let savedTenants = loadTenants() {
            tenants += savedTenants
        }
        else {
            // Load the sample data.
            loadSampleTenants()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tenants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "TenantTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TenantTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TenantTableViewCell.")
        }
        
        // Fetches the appropriate tenant for the data source layout.
        let tenant = tenants[indexPath.row]
        
        cell.nameLabel.text = tenant.name
        cell.currentDueLabel.text = tenant.Currency(amount: tenant.currentDue)
        cell.PhotoImageView.image = tenant.photo
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tenants.remove(at: indexPath.row)
            saveTenants()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
     // Override to support rearranging the table view.
     /*override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        //let item = tenants[sourceIndexPath.row]
     }
    override func tableView
     // Override to support conditional rearranging of the table view.
     
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }*/
    
    //MARK: - Navigation
    
    // Transfers data to other view controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddItem":
            os_log("Adding a new tenant.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let tenantDetailViewController = segue.destination as? TenantDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedTenantCell = sender as? TenantTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedTenantCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedTenant = tenants[indexPath.row]
            tenantDetailViewController.tenant = selectedTenant
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    
    @IBAction func unwindToTenantList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? TenantViewController, let tenant = sourceViewController.tenant {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing tenant.
                tenants[selectedIndexPath.row] = tenant
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new tenant.
                let newIndexPath = IndexPath(row: tenants.count, section: 0)
                tenants.append(tenant)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        else if let sourceViewController = sender.source as? TenantPayViewController, let tenant = sourceViewController.tenant {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing tenant.
                tenants[selectedIndexPath.row] = tenant
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
        }
        else if let sourceViewController = sender.source as? TenantDetailViewController, let tenant = sourceViewController.tenant {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing tenant.
                tenants[selectedIndexPath.row] = tenant
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
        }
        // Save the tenants.
            saveTenants()
    }
    
    //MARK: Private Methods
    
    private func loadSampleTenants() {
        
        let photo1 = UIImage(named: "defaultPhoto copy")
        
        guard let tenant1 = Tenant(name: "John Smith", phoneNumber: "888-888-8888", notes: "", monthRent: 650, currentDue: 0, photo: photo1) else {
            fatalError("Unable to instantiate tenant1")
        }
        
        tenants += [tenant1]
    }
    
    private func saveTenants() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(tenants, toFile: Tenant.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Tenants successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save tenants...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadTenants() -> [Tenant]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Tenant.ArchiveURL.path) as? [Tenant]
    }
}
