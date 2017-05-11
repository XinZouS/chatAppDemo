//
//  UIImage++.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/3/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

let imgCache = NSCache<NSString, UIImage>() // !!!!!!

extension UIImageView {
    
    func loadImageUsingCacheWith(urlString:String) {
        // check image for cache first(before download)!!!
        if let cacheImg = imgCache.object(forKey: urlString as NSString) {
            //print(" -  load image from NSCache: \(cacheImg)")
            self.image = cacheImg
            return
        }
        // else, check disk see if already got it previous:
        if let storedImgData = UserDefaults.standard.value(forKey: urlString) as? Data {
            //print(" -  load image from disk: \(storedImgData)")
            self.image = UIImage(data: storedImgData)
            return
        }
        
        // else, download image: 
        guard let url = URL(string: urlString) else { return }
        // URLSession provides download content to perform background downloads:
        // https://developer.apple.com/reference/foundation/urlsession
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, err) in
            if err != nil {
                print(" ----- UIImageView++.swift: loading user image error: \(err).")
                return
            }
            // get image data and put into tableView:
            DispatchQueue.main.async(execute: {
                if let downedImg = UIImage(data: data!) {
                    imgCache.setObject(downedImg, forKey: urlString as NSString)
                    self.image = downedImg
                    self.saveImageIntoDiskWith(downedImg, urlString)
                }
            })
        }).resume() // !!!!!!

    }

    private func saveImageIntoDiskWith(_ img: UIImage?, _ url: String?){
        guard let img = img, let url = url else { return }
        print(" --- saveImageIntoDiskWith() url: \(url)")
        UserDefaults.standard.set(UIImageJPEGRepresentation(img, 1.0), forKey: url)
        UserDefaults.standard.synchronize()
    }

}


