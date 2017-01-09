//
//  ChatMessageCell.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/6/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit
import Firebase

class ChatMessageCell: UICollectionViewCell {
    
    let textLabel : UITextView = {
        let tv = UITextView()
        //tv.text = "test txt a b c d e f g h i j"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let profileImgView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "chihiroAndHaku03_500x500")
        img.layer.cornerRadius = 16
        img.layer.masksToBounds = true
        img.contentMode = .scaleAspectFill
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    static let blueColor = UIColor(r: 0, g: 150, b: 230)
    static let grayColor = UIColor(r: 220, g: 220, b: 220)
    
    let bubbleView: UIView = {
        let v = UIView()
        v.backgroundColor = blueColor
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // init anchors in ChatLogController.swift: 
    var profileImgLeftAnchor: NSLayoutConstraint?
    var profileImgRightAnchor:NSLayoutConstraint?
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor:  NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // chatPartner image:
        addSubview(profileImgView)
        profileImgView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true
        profileImgLeftAnchor = profileImgView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 7)
        profileImgRightAnchor = profileImgView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5)
        profileImgView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImgView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        // backgroundColor = UIColor.green
        addSubview(bubbleView) // add this first!!!
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -40)
        //bubbleRightAnchor?.isActive = true // initiate it in ChatLogController.swift!
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 43)
        // bubbleLeftAnchor?.isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        // bubbleView.widthAnchor.constraint(equalToConstant: 270).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 230)
        bubbleWidthAnchor?.isActive = true
        
        addSubview(textLabel)
        textLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        textLabel.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        textLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 10).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
