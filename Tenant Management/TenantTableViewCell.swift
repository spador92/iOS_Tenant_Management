//
//  TenantTableViewCell.swift
//  Tenant Management
//
//  Created by Sean Pador on 6/27/17.
//  Copyright © 2017 Rodap. All rights reserved.
//

import UIKit

class TenantTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var currentDueLabel: UILabel!
    @IBOutlet weak var PhotoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
