//
//  ChatLogViewMenuCell.swift
//  chatInFirebase
//
//  Created by Xin Zou on 4/26/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit


class MenuCell : UICollectionViewCell {
    
    var imageViwe : UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFit
        return i
    }()
    
    var titleLabel : UILabel = {
        let t = UILabel()
        //t.backgroundColor = .yellow
        t.font = UIFont.systemFont(ofSize: 16)
        t.textColor = .gray
        t.text = "titleLabel"
        t.textAlignment = .center
        return t
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageViwe)
        imageViwe.addConstraints(left: leftAnchor, top: topAnchor, right: rightAnchor, bottom: bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 30, width: 0, height: 0)
        
        addSubview(titleLabel)
        titleLabel.addConstraints(left: leftAnchor, top: imageViwe.bottomAnchor, right: rightAnchor, bottom: bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 0, width: 0, height: 0)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



