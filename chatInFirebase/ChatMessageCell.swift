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
    
    let bubbleView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(r: 0, g: 150, b: 230)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // backgroundColor = UIColor.green
        addSubview(bubbleView) // add this first!!!
        bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        bubbleView.widthAnchor.constraint(equalToConstant: 270).isActive = true
        
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
