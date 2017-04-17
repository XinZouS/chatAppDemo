//
//  UIView++.swift
//  chatInFirebase
//
//  Created by Xin Zou on 4/7/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

extension UIColor {
    static func rgb(r:CGFloat, g:CGFloat, b:CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

extension UIView {
    
    func addConstraints(left:NSLayoutXAxisAnchor? = nil, top:NSLayoutYAxisAnchor? = nil, right:NSLayoutXAxisAnchor? = nil, bottom:NSLayoutYAxisAnchor? = nil, leftConstent:CGFloat? = 0, topConstent:CGFloat? = 0, rightConstent:CGFloat? = 0, bottomConstent:CGFloat? = 0, width:CGFloat? = 0, height:CGFloat? = 0){
        
        var anchors = [NSLayoutConstraint]()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if left != nil {
            anchors.append(leftAnchor.constraint(equalTo: left!, constant: leftConstent!))
        }
        if top != nil {
            anchors.append(topAnchor.constraint(equalTo: top!, constant: topConstent!))
        }
        if right != nil {
            anchors.append(rightAnchor.constraint(equalTo: right!, constant: -rightConstent!))
        }
        if bottom != nil {
            anchors.append(bottomAnchor.constraint(equalTo: bottom!, constant: -bottomConstent!))
        }
        if let width = width, width > CGFloat(0) {
            anchors.append(widthAnchor.constraint(equalToConstant: width))
        }
        if let height = height, height > CGFloat(0) {
            anchors.append(heightAnchor.constraint(equalToConstant: height))
        }
        
        for anchor in anchors {
            anchor.isActive = true
        }
    }
    
    
    
}


