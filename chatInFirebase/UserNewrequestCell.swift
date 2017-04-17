//
//  UserNewrequestCell.swift
//  chatInFirebase
//
//  Created by Xin Zou on 4/14/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

class UserNewrequestCell : UserCell {
    
    lazy var acceptButton : UIButton = {
        let b = UIButton()
        b.setTitle("✅Add", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        b.backgroundColor = buttonColorGreen
        b.layer.cornerRadius = 6
        b.layer.masksToBounds = true
        b.addTarget(self, action: #selector(acceptRequest), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    lazy var rejectButton : UIButton = {
        let b = UIButton()
        b.setTitle("⛔️Ignore", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        b.backgroundColor = buttonColorRed
        b.layer.cornerRadius = 6
        b.layer.masksToBounds = true
        b.addTarget(self, action: #selector(rejectRequest), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //TODO: self.timeLabel
        
        addSubview(rejectButton)
        rejectButton.addConstraints(left: nil, top: topAnchor, right: rightAnchor, bottom: bottomAnchor, leftConstent: 0, topConstent: 15, rightConstent: 5, bottomConstent: 15, width: 80, height: 0)
        
        addSubview(acceptButton)
        acceptButton.addConstraints(left: nil, top: rejectButton.topAnchor, right: rejectButton.leftAnchor, bottom: rejectButton.bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 5, bottomConstent: 0, width: 80, height: 0)
        
        
    }
    
    func acceptRequest(){
        newMsgVC?.acceptRequest(from: self.user)
    }
    func rejectRequest(){
        newMsgVC?.rejectRequest(of: self.user)
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


