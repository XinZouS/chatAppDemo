//
//  UIImage++.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/3/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

//let imgCache = NSCache<AnyObject, AnyObject>() // !!!!!!
let imgCache = NSCache<NSString, UIImage>() // !!!!!!

extension UIImageView {
    
    func loadImageUsingCacheWith(urlString:String) {
        // check image for cache first(before download)!!!
        if let cacheImg = imgCache.object(forKey: urlString as NSString) {
            self.image = cacheImg
            return
        }
        // else, download image: 
        guard let url = URL(string: urlString) else { return }
        // URLSession provides download content to perform background downloads:
        // https://developer.apple.com/reference/foundation/urlsession
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, err) in
            if err != nil {
                print("loading user image error: \(err). ----- UIImageView++.swift: 19")
                return
            }
            // get image data and put into tableView:
            DispatchQueue.main.async(execute: {
                if let downedImg = UIImage(data: data!) {
                    imgCache.setObject(downedImg, forKey: urlString as NSString)
                    self.image = downedImg
                }
            })
        }).resume() // !!!!!!

    }
    
}


