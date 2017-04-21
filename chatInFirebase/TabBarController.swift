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
        newMsgView.messageVC = messagesView
        messagesView.newMsgVC = newMsgView
        //newMsgView.currUser = messagesView.currUser // BUG: if run this line, will crash by nil;
        let newMsgNavController = UINavigationController(rootViewController: newMsgView)
        newMsgNavController.title = "Friends"
        //newMsgNavController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        newMsgNavController.tabBarItem.image = #imageLiteral(resourceName: "catNdog80x80@1x")
        
        let myProfileView = ProfileViewController()
        myProfileView.msgViewController = messagesView
        messagesView.profileVC = myProfileView
        let profileController = UINavigationController(rootViewController: myProfileView)
        profileController.title = "About me"
        profileController.tabBarItem.image = #imageLiteral(resourceName: "dogID_80x80@1x")

        
        self.viewControllers = [msgNavController, newMsgNavController, profileController]
        
        
    }
}

