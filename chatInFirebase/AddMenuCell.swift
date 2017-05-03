//
//  AddMenuCell.swift
//  chatInFirebase
//
//  Created by Xin Zou on 5/2/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

class AddMenuCell : UICollectionViewCell {
    
    let imageView : UIImageView = {
        let i = UIImageView()
        i.image = #imageLiteral(resourceName: "paw-print_64x64@1x")
        i.contentMode = .scaleAspectFit
        return i
    }()
    
    let titleLabel: UILabel = {
        let t = UILabel()
        t.text = "Add menu titleLabel"
        t.textColor = .purple // buttonColorPurple
        t.font = UIFont.systemFont(ofSize: 14)
        t.textAlignment = .left
        return t
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let d : CGFloat = 8 // margin in cell
        
        self.addSubview(imageView)
        imageView.addConstraints(left: leftAnchor, top: topAnchor, right: nil, bottom: bottomAnchor, leftConstent: d, topConstent: d, rightConstent: 0, bottomConstent: d, width: 30, height: 0)
        
        self.addSubview(titleLabel)
        titleLabel.addConstraints(left: imageView.rightAnchor, top: topAnchor, right: rightAnchor, bottom: bottomAnchor, leftConstent: 5, topConstent: d, rightConstent: d, bottomConstent: d, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

