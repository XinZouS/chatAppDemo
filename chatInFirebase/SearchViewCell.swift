//
//  SearchViewCell.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/19/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

class SearchViewCell : UICollectionViewCell {
    
    var searchVC : SearchViewController?
    
    var friend : User? {
        didSet{
            userImgView.loadImageUsingCacheWith(urlString: (friend?.profileImgURL)!)
            userNameLabel.text = friend?.name ?? "Missing name"
            userEmailLabel.text = friend?.email ?? "Missing email"
        }
    }
    
    let userImgView: UIImageView = {
        let img = UIImageView()
        img.image = #imageLiteral(resourceName: "guaiqiao01")
        img.layer.cornerRadius = 23
        img.layer.masksToBounds = true
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    let userNameLabel : UILabel = {
        let b = UILabel()
        b.text = "userNameLabel"
        b.font = UIFont.systemFont(ofSize: 16)
        return b
    }()
    
    let userEmailLabel: UILabel = {
        let b = UILabel()
        b.text = "userEmailLabel"
        b.textColor = UIColor.gray
        b.font = UIFont.systemFont(ofSize: 14)
        return b
    }()
    
    lazy var sendRequestButton: UIButton = {
        let b = UIButton()
        b.setTitle("Add", for: .normal)
        b.layer.cornerRadius = 6
        b.layer.masksToBounds = true
        b.backgroundColor = buttonColorGreen
        b.addTarget(self, action: #selector(sendFriendRequestToSelectedUser), for: .touchUpInside)
        return b
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(userImgView)
        userImgView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        userImgView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        userImgView.widthAnchor.constraint(equalToConstant: 46).isActive = true
        userImgView.heightAnchor.constraint(equalToConstant: 46).isActive = true
        
        addSubview(sendRequestButton)
        sendRequestButton.addConstraints(left: nil, top: topAnchor, right: rightAnchor, bottom: bottomAnchor, leftConstent: 0, topConstent: 8, rightConstent: 10, bottomConstent: 8, width: 80, height: 0)
        
        addSubview(userNameLabel)
        userNameLabel.addConstraints(left: userImgView.rightAnchor, top: topAnchor, right: sendRequestButton.leftAnchor, bottom: nil, leftConstent: 10, topConstent: 8, rightConstent: 5, bottomConstent: 0, width: 0, height: 20)
        
        addSubview(userEmailLabel)
        userEmailLabel.addConstraints(left: userNameLabel.leftAnchor, top: userNameLabel.bottomAnchor, right: userNameLabel.rightAnchor, bottom: nil, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 0, width: 0, height: 20)
    }
    
    func sendFriendRequestToSelectedUser(){
        searchVC!.sendFriendRequestTo(userId: self.friend?.id)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
