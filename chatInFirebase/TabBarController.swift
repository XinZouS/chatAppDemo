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
        msgNavController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        //msgNavController.tabBarItem.image = UIImage(named: "doge_200x200")
        
        let newMsgView = NewMessageViewController()
        let newMsgNavController = UINavigationController(rootViewController: newMsgView)
        newMsgNavController.title = "My Friends"
        newMsgNavController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        //newMsgNavController.tabBarItem.image = UIImage(named: "paw-print_512x512")

//        // this view should be put into NewMessageViewController as its subview;
//        let searchView = SearchViewController(collectionViewLayout: UICollectionViewFlowLayout())
//        let searchNavController = UINavigationController(rootViewController: searchView)
//        searchNavController.title = "New Friends"
//        searchNavController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 2)
//        //searchNavController.tabBarItem.image = UIImage(named: "")
        
        self.viewControllers = [msgNavController, newMsgNavController]
    }
}
