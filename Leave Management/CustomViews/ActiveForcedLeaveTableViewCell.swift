//
//  ActiveForcedLeaveTableViewCell.swift
//  Leave Management
//
//  Created by Dominic Tabu on 24/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit

class ActiveForcedLeaveTableViewCell: UITableViewCell {

    @IBOutlet weak var employeeName: UILabel!
    @IBOutlet weak var reason: UILabel!
    @IBOutlet weak var dateIssued: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
