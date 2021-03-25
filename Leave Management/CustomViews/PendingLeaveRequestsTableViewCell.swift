//
//  PendingLeaveRequestsTableViewCell.swift
//  Leave Management
//
//  Created by Dominic Tabu on 11/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import UIKit

class PendingLeaveRequestsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var employeeName: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var leaveDays: UILabel!
    @IBOutlet weak var endDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
