//
//  NamecardController.swift
//  chatInFirebase
//
//  Created by Xin Zou on 5/3/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit


class NamecardController : UIViewController, UINavigationControllerDelegate {
    
    var partnerUser : User?
    
    let profileImgView : UIImageView = {
        let v = UIImageView()
        return v
    }()
    
    let nameLabel : UILabel = {
        let l = UILabel()
        l.text = "Name"
        l.textColor = .gray
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()
    
    let nameOfUserLabel : UILabel = {
        let l = UILabel()
        l.text = "user name"
        l.font = UIFont.systemFont(ofSize: 18)
        return l
    }()
    
    let emailLabel: UILabel = {
        let l = UILabel()
        l.text = "Email"
        l.textColor = .gray
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()
    
    let emailOfUserLabel : TopAlignedLabel = {
        let l = TopAlignedLabel()
        l.text = "user email"
        l.font = UIFont.systemFont(ofSize: 16)
        l.numberOfLines = 2
        return l
    }()
    
    let introduceOfUserTextView : UITextView = {
        let t = UITextView()
        t.isEditable = false
        t.layer.borderWidth = 1
        t.layer.borderColor = (UIColor.lightGray).cgColor
        t.isEditable = false
        return t
    }()
    
    let msgButton : UIButton = {
        let b = UIButton()
        b.setTitle("Message", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        b.backgroundColor = buttonColorPurple
        b.layer.cornerRadius = 8
        b.layer.masksToBounds = true
        b.addTarget(self, action: #selector(gotoMessagePage), for: .touchUpInside)
        return b
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tabBarController?.hideTabBarWithAnimation(toHide: true)
        
        setupContents()
        setupFriendInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.hideTabBarWithAnimation(toHide: false)
    }
    
    
    func setupContents(){
        let sideLen : CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 100 : 200
        view.addSubview(profileImgView)
        profileImgView.addConstraints(left: view.leftAnchor, top: view.topAnchor, right: nil, bottom: nil, leftConstent: 20, topConstent: 85, rightConstent: 0, bottomConstent: 0, width: sideLen, height: sideLen)
        //------------------------------
        view.addSubview(nameLabel)
        nameLabel.addConstraints(left: profileImgView.rightAnchor, top: profileImgView.topAnchor, right: view.rightAnchor, bottom: nil, leftConstent: 10, topConstent: 0, rightConstent: 20, bottomConstent: 0, width: 0, height: 20)
        
        view.addSubview(nameOfUserLabel)
        nameOfUserLabel.addConstraints(left: nameLabel.leftAnchor, top: nameLabel.bottomAnchor, right: nameLabel.rightAnchor, bottom: nil, leftConstent: 0, topConstent: sideLen / 20, rightConstent: 0, bottomConstent: 0, width: 0, height: 20)
        
        view.addSubview(emailLabel)
        emailLabel.addConstraints(left: nameLabel.leftAnchor, top: nameOfUserLabel.bottomAnchor, right: nameLabel.rightAnchor, bottom: nil, leftConstent: 0, topConstent: 10, rightConstent: 0, bottomConstent: 0, width: 0, height: 20)
        
        view.addSubview(emailOfUserLabel)
        emailOfUserLabel.addConstraints(left: nameLabel.leftAnchor, top: emailLabel.bottomAnchor, right: nameLabel.rightAnchor, bottom: nil, leftConstent: 0, topConstent: 5, rightConstent: 0, bottomConstent: 0, width: 0, height: 40)
        //------------------------------
        view.addSubview(introduceOfUserTextView)
        introduceOfUserTextView.addConstraints(left: profileImgView.leftAnchor, top: profileImgView.bottomAnchor, right: nameLabel.rightAnchor, bottom: nil, leftConstent: 0, topConstent: 30, rightConstent: 0, bottomConstent: 0, width: 0, height: 100)
        
        view.addSubview(msgButton)
        msgButton.addConstraints(left: profileImgView.leftAnchor, top: introduceOfUserTextView.bottomAnchor, right: nameLabel.rightAnchor, bottom: nil, leftConstent: 0, topConstent: 60, rightConstent: 0, bottomConstent: 0, width: 0, height: 50)
        
    }
    
    func setupFriendInfo(){
        guard let url = partnerUser?.profileImgURL, let name = partnerUser?.name, let email = partnerUser?.email else { return }
        profileImgView.loadImageUsingCacheWith(urlString: url)
        nameOfUserLabel.text = name
        emailOfUserLabel.text = email
    }
    
    func gotoMessagePage(){
        _ = navigationController?.popViewController(animated: true)
    }
    
}
