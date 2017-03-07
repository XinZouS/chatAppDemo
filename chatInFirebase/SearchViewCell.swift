//
//  SearchViewCell.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/19/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

class SearchViewCell : UICollectionViewCell {
    
    var user : User?
    
    let userImgView: UIImageView = {
        let img = UIImageView()
        //img.image = UIImage(named: "chihiroAndHaku03_500x500")
        img.layer.cornerRadius = 16
        img.layer.masksToBounds = true
        img.contentMode = .scaleAspectFill
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(userImgView)
        userImgView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10)
        userImgView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        userImgView.widthAnchor.constraint(equalToConstant: 32)
        userImgView.heightAnchor.constraint(equalToConstant: 32)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
