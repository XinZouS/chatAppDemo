//
//  Message.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/4/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit
import Firebase

class Message : NSObject, NSCoding {
    
    var fromId: String?
    var toId: String?
    var text: String?
    var timeStamp: NSNumber?
    var isDeletedByPartner: Bool?
    
    var fileName: String?
    
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
        isDeletedByPartner = dictionary["isDeletedByPartner"] as? Bool
        
        fileName = dictionary["fileName"] as? String
        
        imgURL  =   dictionary["imgURL"]  as? String
        imgWidth =  dictionary["imgWidth"] as? NSNumber
        imgHeight = dictionary["imgHeight"] as? NSNumber
        
        videoURL = dictionary["videoURL"] as? String
    }
    
    
    
    // for save into UserDefault: ===========================================
    required convenience init(coder aDecoder: NSCoder) {
        let fromId = aDecoder.decodeObject(forKey: "fromId") as? String
        let toId   = aDecoder.decodeObject(forKey: "toId")   as? String
        let text   = aDecoder.decodeObject(forKey: "text")   as? String
        let timeStamp = aDecoder.decodeObject(forKey: "timeStamp") as? NSNumber
        let isDeletedByPartner = aDecoder.decodeObject(forKey: "isDeletedByPartner") as? Bool
        
        let fileName = aDecoder.decodeObject(forKey: "fileName") as? String
        
        let imgURL = aDecoder.decodeObject(forKey: "imgURL") as? String
        let imgWidth = aDecoder.decodeObject(forKey: "imgWidth") as? NSNumber
        let imgHeight = aDecoder.decodeObject(forKey: "imgHeight") as? NSNumber
        
        let videoURL = aDecoder.decodeObject(forKey: "videoURL") as? String
        
        let decodeDict : [String: Any] = [
            "fromId" : fromId, "toId" : toId, "text" : text, "timeStamp" : timeStamp,
            "isDeletedByPartner" : isDeletedByPartner, "fileName" : fileName,
            "imgURL" : imgURL, "imgWidth" : imgWidth, "imgHeight" : imgHeight,
            "videoURL" : videoURL
        ]
        self.init(dictionary: decodeDict)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(fromId, forKey: "fromId")
        aCoder.encode(toId, forKey: "toId")
        aCoder.encode(text, forKey: "text")
        aCoder.encode(timeStamp, forKey: "timeStamp")
        aCoder.encode(isDeletedByPartner, forKey: "isDeletedByPartner")

        aCoder.encode(fileName, forKey: "fileName")
        
        aCoder.encode(imgURL, forKey: "imgURL")
        aCoder.encode(imgWidth, forKey: "imgWidth")
        aCoder.encode(imgHeight, forKey: "imgHeight")
        
        aCoder.encode(videoURL, forKey: "videoURL")
    }

}

