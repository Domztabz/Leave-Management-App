//
//  RejectedLeaveTableViewCell.swift
//  Leave Management
//
//  Created by Dominic Tabu on 13/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import UIKit

class RejectedLeaveRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var employeesName: UILabel!
    
    
    @IBOutlet weak var supervisor: UILabel!
    
    @IBOutlet weak var typeOfLeave: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
