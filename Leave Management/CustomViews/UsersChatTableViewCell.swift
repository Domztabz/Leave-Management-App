//
//  UsersChatTableViewCell.swift
//  Leave Management
//
//  Created by Dominic Tabu on 24/10/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit

class UsersChatTableViewCell: UITableViewCell {

//    @IBOutlet weak var profilePicture: UIImageView!
//    @IBOutlet weak var lastMessageUILabel: UILabel!
    @IBOutlet weak var userNameUILabel: UILabel!
    
    
    @IBOutlet weak var labelLastLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
