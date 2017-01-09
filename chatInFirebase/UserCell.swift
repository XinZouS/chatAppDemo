//
//  UserCell.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/5/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit
import Firebase


class UserCell : UITableViewCell {
 
    var message: Message? {
        didSet {
            setupNameAndProfileImg()
            
            detailTextLabel?.text = message?.text
 
            if let seconds = message?.timeStamp?.doubleValue {
                // NSNumber(value: Int(Date().timeIntervalSince1970))
                let timeStampDate = Date(timeIntervalSince1970: seconds)
                let formater = DateFormatter()
                formater.dateFormat = "hh:mm:ss a"
                // timeLabel.text = timeStampData.description
                timeLabel.text = formater.string(from: timeStampDate)
            }
            
        }
    }
    private func setupNameAndProfileImg(){ // in message{didSet{..}}
        // cell.textLabel?.text = msg.toId // use toId to get name display:
        if let partnerId = message?.chatPartnerId() {
            let ref = FIRDatabase.database().reference().child("users").child(partnerId) // get user's ID
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                // print("indexPath.row = \(indexPath.row)")
                // print(snapshot)
                if let dictionary = snapshot.value as? [String: Any] {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImgUrl = dictionary["profileImgURL"] as? String {
                        self.profileImageView.loadImageUsingCacheWith(urlString: profileImgUrl)
                    }
                }
            }, withCancel: nil)
        }
        
    }
    
    var profileImageView: UIImageView = {
        var imgView = UIImageView()
        imgView.image = UIImage(named: "chihiroAndHaku03_500x500")
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false // for our modify affect;
        imgView.layer.cornerRadius = 23
        imgView.layer.masksToBounds = true
        return imgView
    }()
    
    var timeLabel: UILabel = {
        var lab = UILabel()
        //lab.text = "HH:MM:SS"
        lab.textColor = UIColor(r: 200, g: 200, b: 200)
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.translatesAutoresizingMaskIntoConstraints = false
        return lab
    }()
    
    // use this to avoid image blocks labels:
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 9).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 46).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 46).isActive = true
        
        self.addSubview(timeLabel)
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 10).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: self.topAnchor, constant: 30).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
    }
    // and add this:
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder) has not been implented!! NewMessageViewController.swift: 90")
    }
}





