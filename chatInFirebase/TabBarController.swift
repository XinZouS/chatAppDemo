//
//  TabBarController.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/19/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let messagesView = MessagesViewController()
        let msgNavController = UINavigationController(rootViewController: messagesView)
        msgNavController.title = "Chats"
        //msgNavController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        msgNavController.tabBarItem.image = #imageLiteral(resourceName: "doge_80x86@1x")
        
        let newMsgView = NewMessageViewController()
        let newMsgNavController = UINavigationController(rootViewController: newMsgView)
        newMsgNavController.title = "Friends"
        //newMsgNavController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        newMsgNavController.tabBarItem.image = #imageLiteral(resourceName: "catNdog80x80@1x")
        
        let myProfileView = UIViewController() // ProfileViewController()
        let profileController = UINavigationController(rootViewController: myProfileView)
        profileController.title = "About me"
        profileController.tabBarItem.image = #imageLiteral(resourceName: "dogID_80x80@1x")

//        // this view should be put into NewMessageViewController as its subview;
//        let searchView = SearchViewController(collectionViewLayout: UICollectionViewFlowLayout())
//        let searchNavController = UINavigationController(rootViewController: searchView)
//        searchNavController.title = "New Friends"
//        searchNavController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 2)
//        //searchNavController.tabBarItem.image = UIImage(named: "")
        
        self.viewControllers = [msgNavController, newMsgNavController, profileController]
    }
}
