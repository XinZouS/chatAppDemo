//
//  UINavigationController++.swift
//  chatInFirebase
//
//  Created by Xin Zou on 4/17/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit


extension UINavigationController {
    
    func setupNavBarWithUser(user: User, in vc: UIViewController) {
        // self.navigationItem.title = user.name // but this can only set name, we need img using:
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 210, height: 40)
        
        let containerView = UIView() // for adjuse titleLabel when it is too loooong
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        if let profileImageUrl = user.profileImgURL {
            profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
        }
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        containerView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 9).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        vc.navigationItem.titleView = titleView
        
    }
    
    
}
