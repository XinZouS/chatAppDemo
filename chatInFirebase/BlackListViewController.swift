//
//  BlackListViewController.swift
//  chatInFirebase
//
//  Created by Xin Zou on 5/16/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit
import Firebase


class BlackListViewController : UITableViewController, UINavigationControllerDelegate {
    
    var msgVC : MessagesViewController?
    
    var blackListUsers = [User]()
    
    let cellId = "BlackListCellID"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        navigationItem.title = "Blocked Users"
        
        tableView.register(BlackListCell.self, forCellReuseIdentifier: cellId)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUsersFromFirebase()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.hideTabBarWithAnimation(toHide: false)
        blackListUsers.removeAll()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blackListUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < (msgVC?.currUser.blackList?.count)! else {
            return BlackListCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! BlackListCell
        cell.userBlocked = blackListUsers[indexPath.row]
        cell.blackListVC = self
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func fetchUsersFromFirebase(){
        guard var idList = msgVC?.currUser.blackList, idList.count > 0 else { return }
        
        for i in 0..<idList.count {
            if idList[i] == "" || idList[i] == " " {
                idList.remove(at: i)
                msgVC?.currUser.blackList?.remove(at: i)
                msgVC?.saveUserIntoDisk()
                break
            }
        }
        let ref = FIRDatabase.database().reference().child("users")
        for id in idList {
            ref.child(id).observeSingleEvent(of: .value, with: {(snapshot) in
                let getId = snapshot.key as String
                if let dict = snapshot.value as? [String:AnyObject] {
                    let newUser = User(dictionary: dict)
                    newUser.id = getId
                    self.blackListUsers.append(newUser)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
        
    func removeUserFromBlackListBy(_ id : String){
        guard var blackListIds = msgVC?.currUser.blackList, let myId = msgVC?.currUser.id else { return }
        for i in 0..<blackListUsers.count {
            if blackListIds[i] == id {
                blackListIds.remove(at: i)
                blackListUsers.remove(at: i)
                msgVC?.currUser.blackList?.remove(at: i)
                msgVC?.saveUserIntoDisk()
                
                let ref = FIRDatabase.database().reference().child("users").child(myId).child("blackList")
                ref.setValue(blackListIds)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                break
            }
        }
    }
    
}

