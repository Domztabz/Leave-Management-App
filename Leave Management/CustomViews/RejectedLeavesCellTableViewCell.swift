//
//  RejectedLeavesCellTableViewCell.swift
//  Leave Management
//
//  Created by Dominic Tabu on 17/04/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit

class RejectedLeavesCellTableViewCell: UITableViewCell {

    @IBOutlet weak var numberOfRelievers: UILabel!
    @IBOutlet weak var leaveDays: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var department: UILabel!
    @IBOutlet weak var employeeName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
