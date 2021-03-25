//
//  TextInputTextField.swift
//  Leave Management
//
//  Created by Dominic Tabu on 10/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import UIKit

@IBDesignable class TextInputTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpField()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init( coder: aDecoder )
        setUpField()
    }
    
    
    private func setUpField() {
        //tintColor             = .white
        textColor             = .darkGray
        font                  = UIFont(name: "AvenirNextCondensed-DemiBold", size: 18)
        autocorrectionType    = .no
        layer.cornerRadius    = 5.0
        clipsToBounds         = true
        layer.borderWidth = 1.0
        layer.borderColor = #colorLiteral(red: 0.768627451, green: 0.8039215686, blue: 0.8784313725, alpha: 1)
        backgroundColor = #colorLiteral(red: 0.768627451, green: 0.8039215686, blue: 0.8784313725, alpha: 1)
        let placeholder       = self.placeholder != nil ? self.placeholder! : ""
        let placeholderFont   = UIFont(name: "AvenirNextCondensed-DemiBold", size: 18)!
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes:
            [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
             NSAttributedString.Key.font: placeholderFont])
        
        let indentView        = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        leftView              = indentView
        leftViewMode          = .always
    }

}
