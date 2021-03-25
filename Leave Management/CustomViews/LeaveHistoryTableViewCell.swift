//
//  LeaveHistoryTableViewCell.swift
//  Leave Management
//
//  Created by Dominic Tabu on 10/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit

class LeaveHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var typeOfLeaveUILabel: UILabel!
    @IBOutlet weak var startDateUILabel: UILabel!
    @IBOutlet weak var endDateUILabel: UILabel!
    @IBOutlet weak var leaveDaysUILabel: UILabel!
    @IBOutlet weak var hODResponseUILabel: UILabel!
    @IBOutlet weak var hRResponseUILabel: UILabel!
    @IBOutlet weak var mDResponseUILabel: UILabel!
    @IBOutlet weak var relieverResponseUILabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
