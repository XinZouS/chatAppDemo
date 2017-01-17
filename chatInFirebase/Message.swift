//
//  Message.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/4/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit
import Firebase

class Message : NSObject {
    
    var fromId: String?
    var toId: String?
    var text: String?
    var timeStamp: NSNumber?
    
    var imgURL: String?
    var imgWidth: NSNumber?
    var imgHeight:NSNumber?
    
    var videoURL: String?
    
    func chatPartnerId() -> String? {
//        return (fromId! == FIRAuth.auth()?.currentUser?.uid) ? (toId!) : (fromId!)
        return fromId == (FIRAuth.auth()?.currentUser?.uid) ? toId : fromId
    }
    
    init(dictionary: [String: Any]) {
        super.init()
        
        fromId  = dictionary["fromId"]  as? String
        toId    = dictionary["toId"]    as? String
        text    = dictionary["text"]    as? String
        timeStamp = dictionary["timeStamp"] as? NSNumber
        
        imgURL  =   dictionary["imgURL"]  as? String
        imgWidth =  dictionary["imgWidth"] as? NSNumber
        imgHeight = dictionary["imgHeight"] as? NSNumber
        
        videoURL = dictionary["videoURL"] as? String
    }
    
}

