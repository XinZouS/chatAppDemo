//
//  BlackListCell.swift
//  chatInFirebase
//
//  Created by Xin Zou on 5/16/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit


class BlackListCell : UserCell {
    
    var blackListVC : BlackListViewController?
    
    var userBlocked: User? {
        didSet{
            guard let url = userBlocked?.profileImgURL else { return }
            textLabel?.text = userBlocked?.name
            profileImageView.loadImageUsingCacheWith(urlString: (userBlocked?.profileImgURL)!)
        }
    }
    
    
    lazy var removeButton: UIButton = {
        let b = UIButton()
        b.backgroundColor = buttonColorOrange
        b.setTitle("↪️ Remove", for: .normal)
        b.titleLabel?.textAlignment = .center
        b.layer.cornerRadius = 8
        b.layer.masksToBounds = true
        b.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        return b
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let c : CGFloat = 12
        self.addSubview(removeButton)
        removeButton.addConstraints(left: nil, top: topAnchor, right: rightAnchor, bottom: bottomAnchor, leftConstent: 0, topConstent: c, rightConstent: c, bottomConstent: c, width: 116, height: 0)
    }
    
    func removeButtonTapped(){
        guard let id = self.userBlocked?.id else { return }
        blackListVC?.removeUserFromBlackListBy(id)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
