//
//  PastLeavesTableViewCell.swift
//  Leave Management
//
//  Created by Dominic Tabu on 26/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit

class PastLeavesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var type: UILabel!
    
    @IBOutlet weak var startDate: UILabel!
    
    @IBOutlet weak var endDate: UILabel!
    
    @IBOutlet weak var employeeName: UILabel!
    
    @IBOutlet weak var leaveDays: UILabel!
    
    @IBOutlet weak var relieverResponse: UILabel!
        
    @IBOutlet weak var hodResponse: UILabel!
    
    @IBOutlet weak var mdResponse: UILabel!
    @IBOutlet weak var hrResponse: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
