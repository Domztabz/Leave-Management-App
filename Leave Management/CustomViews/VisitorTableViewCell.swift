//
//  VisitorTableViewCell.swift
//  Leave Management
//
//  Created by Dominic Tabu on 04/02/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit

class VisitorTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var visitorImage: UIImageView!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
