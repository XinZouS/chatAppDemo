//
//  User.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/1/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

class User : NSObject, NSCoding {
    
    var id : String?
    var name : String?
    var email: String?
    var signature: String?
    var profileImgURL: String?
    var friends: [String]?   // [userID]
    var blackList: [String]? // [userID]
    
    override init() {
        id = ""
        name = ""
        email = ""
        signature = ""
        profileImgURL = ""
        friends = [""]
        blackList = [""]
    }
    init(id: String?, name: String?, email:String?, signature:String?, profileImgUrl:String?, friendList:[String]?, blackList: [String]?) {
        self.id = id
        self.name = name
        self.email = email
        self.signature = signature
        self.profileImgURL = profileImgUrl
        self.friends = friendList
        self.blackList = blackList
    }
    init(dictionary: [String: AnyObject]) {
        super.init()        
        id  = dictionary["id"] as? String
        name = dictionary["name"] as? String
        email = dictionary["email"] as? String
        signature = dictionary["signature"] as? String
        profileImgURL = dictionary["profileImgURL"] as? String
        friends = dictionary["friends"] as? [String]
        blackList = dictionary["blackList"] as? [String]
    }

    // for save into disk on device:
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as? String
        let name = aDecoder.decodeObject(forKey: "name") as? String
        let email = aDecoder.decodeObject(forKey: "email") as? String
        let signature = aDecoder.decodeObject(forKey: "signature") as? String
        let profileImgUrl = aDecoder.decodeObject(forKey: "profileImgURL") as? String
        let friends = aDecoder.decodeObject(forKey: "friends") as? [String]
        let blackList = aDecoder.decodeObject(forKey: "blackList") as? [String]
        self.init(id: id, name: name, email: email, signature: signature, profileImgUrl: profileImgUrl, friendList: friends, blackList: blackList)
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(signature, forKey: "signature")
        aCoder.encode(profileImgURL, forKey: "profileImgURL")
        aCoder.encode(friends, forKey: "friends")
        aCoder.encode(blackList, forKey: "blackList")
    }
    
    func printContents(){
        print(" - id: ", id)
        print(" - name: ", name)
        print(" - email: ", email)
        print(" - signature: ", signature)
        print(" - URL: ", profileImgURL)
        print(" - friends: ", friends)
        print(" - blackList: ", blackList)
    }
}
