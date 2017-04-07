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
    var profileImgURL: String?
    
    var friends: [String]? // [userID]
    
    override init() {
        id = ""
        name = ""
        email = ""
        profileImgURL = ""
        friends = [""]
    }
    init(id: String?, name: String?, email:String?, profileImgUrl:String?, friendList:[String]?) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImgURL = profileImgUrl
        self.friends = friendList
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as? String
        let name = aDecoder.decodeObject(forKey: "name") as? String
        let email = aDecoder.decodeObject(forKey: "email") as? String
        let profileImgUrl = aDecoder.decodeObject(forKey: "profileImgURL") as? String
        let friends = aDecoder.decodeObject(forKey: "friends") as? [String]
        self.init(id: id, name: name, email: email, profileImgUrl: profileImgUrl, friendList: friends)
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(profileImgURL, forKey: "profileImgURL")
        aCoder.encode(friends, forKey: "friends")
    }
    
    func printContents(){
        print(" - id: ", id)
        print(" - name: ", name)
        print(" - email: ", email)
        print(" - URL: ", profileImgURL)
        print(" - friends: ", friends)
    }
}
