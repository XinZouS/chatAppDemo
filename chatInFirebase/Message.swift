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
    
    func chatPartnerId() -> String? {
//        return (fromId! == FIRAuth.auth()?.currentUser?.uid) ? (toId!) : (fromId!)
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
    
}

