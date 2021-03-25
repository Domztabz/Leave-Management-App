//
//  UIView+Additions.swift
//  Leave Management
//
//  Created by Dominic Tabu on 22/10/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit

extension UIView {
    
    func smoothRoundCorners(to radius: CGFloat) {
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: radius
            ).cgPath
        
        layer.mask = maskLayer
    }
    
}

