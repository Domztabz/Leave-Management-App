//
//  GoBackButton.swift
//  Leave Management
//
//  Created by Dominic Tabu on 13/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GoBackbutton: UIButton {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupButton()
    }
    
    func setupButton() {
        backgroundColor     = #colorLiteral(red: 0.1568627451, green: 0.2, blue: 0.462745098, alpha: 1)
        titleLabel?.font    = UIFont(name: "AvenirNextCondensed-DemiBold", size: 22)
        layer.cornerRadius = frame.size.height / 2
        setTitleColor(.white, for: .normal)
        layer.borderWidth = 2.0
        layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
    }
    
    
    
}
