//
//  CustomSelectedTableViewCell.swift
//  Leave Management
//
//  Created by Dominic Tabu on 16/04/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit

class CustomSelectedTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none


        // Configure the view for the selected state
    }

}
