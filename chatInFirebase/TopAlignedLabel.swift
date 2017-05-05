//
//  TopAlignedLabel.swift
//  chatInFirebase
//
//  Created by Xin Zou on 5/4/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

@IBDesignable class TopAlignedLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        if let stringText = text {
            let stringTextAsNSString = stringText as NSString
            
            let sz = CGSize(width: self.frame.width,height: CGFloat.greatestFiniteMagnitude)
            let op = NSStringDrawingOptions.usesLineFragmentOrigin
            let atb = [NSFontAttributeName: font]
            let labelStringSize = stringTextAsNSString.boundingRect(with: sz, options: op, attributes: atb, context: nil).size
            
            super.drawText(in: CGRect(x:0,y: 0,width: self.frame.width, height:ceil(labelStringSize.height)))
        } else {
            super.drawText(in: rect)
        }
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
}



