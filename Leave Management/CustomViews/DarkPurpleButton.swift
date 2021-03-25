//
//  DarkPurpleButton.swift
//  Leave Management
//
//  Created by Dominic Tabu on 28/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit

 @IBDesignable class DarkPurpleButton: UIButton {

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
    }

}
