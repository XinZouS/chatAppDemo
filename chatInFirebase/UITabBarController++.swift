//
//  UITabBarController++.swift
//  chatInFirebase
//
//  Created by Xin Zou on 5/3/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

extension UITabBarController {
    
    func hideTabBarWithAnimation(toHide: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            if toHide {
                self.tabBar.transform = CGAffineTransform(translationX: 0, y: 50)
            } else {
                self.tabBar.transform = CGAffineTransform.identity
            }
        })
    }
    
}

