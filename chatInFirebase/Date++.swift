//
//  Date++.swift
//  chatInFirebase
//
//  Created by Xin Zou on 4/7/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import Foundation


extension Date {
    func timeAgoDispaly() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let formater = DateFormatter()
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
//        let month = 4 * week
        
        if secondsAgo < minute {
            return "\(secondsAgo) seconds ago"
        }
        else if secondsAgo < hour {
            return "\(secondsAgo / minute) minutes ago"
        }
        else if secondsAgo < day {
//            return "\(secondsAgo / hour) hours ago"
            formater.dateFormat = "hh:mm:ss a"
            return formater.string(from: self)
        }
        else if secondsAgo < week {
            return "\(secondsAgo / day) days ago"
        }
//        else if secondsAgo < month {
//            return "\(secondsAgo / week) weeks ago"
            formater.dateFormat = "MMM dd,yyyy"
            return formater.string(from: self)
//        }
//        return "\(secondsAgo / month) month ago"
        
    }
    
}

// how to use:
//let now = Date()
//let pastDate = Date(timeIntervalSinceNow: -1000) // seconds
//pastDate.timeAgoDispaly() // 17 min ago


