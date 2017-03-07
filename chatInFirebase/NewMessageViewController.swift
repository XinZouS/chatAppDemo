//
//  NewMessageViewController.swift
//  chatInFirebase
//
//  Created by Xin Zou on 12/31/16.
//  Copyright © 2016 Xin Zou. All rights reserved.
//

import UIKit
import Firebase

class NewMessageViewController: UITableViewController {
    
    var myFriends = [User]()
    let cellId = "cellId"

    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelNewMessage))
        
        
        // change tableViewCell at UserCell.class (at bottom of this file)
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

        fetchUser()
    }
    
    func fetchUser(){

        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            //print(snapshot)  // JSON data of users, one by one, use array to load all users:

            if let dictionary = snapshot.value as? [String:AnyObject] {
                let user = User()
                user.id = snapshot.key
                // if using this way, the class properties MUST match the exactly structure with data in Firebase, or it will crash!
                // aka : user.name = dictionary["name"]
                user.setValuesForKeys(dictionary)
                self.myFriends.append(user)
                // print("get user name: \(user.name) and email: \(user.email)")
                
                // to avoid crash, use dispatch_async to load users into table:
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            
        }, withCancel: nil)
        
    }
    
    func cancelNewMessage(){
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFriends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//         let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
//         let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = myFriends[indexPath.row]

        cell.textLabel?.text = user.name!
        cell.detailTextLabel?.text = user.email!
//        cell.imageView?.image = UIImage(named: "chihiroAndHaku03_500x500")
//        cell.imageView?.contentMode = .scaleAspectFit

        if let profileImgURL = user.profileImgURL {
            //--- better way to load img -----------------------------------------
            cell.profileImageView.loadImageUsingCacheWith(urlString: profileImgURL)

            //--- too much download way ------------------------------------------
//            let url = URL(string: profileImgURL)
//            
//            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, err) in
//                if err != nil {
//                    print("loading user image error: \(err). ----- NewMessageViewController.swift: 89")
//                    return
//                }
//                // get image data and put into tableView:
//                DispatchQueue.main.async(execute: {
//                    cell.profileImageView.image = UIImage(data: data!)
//                    // cell.imageView?.image = UIImage(data: data!)
//                })
//            }).resume() // !!!!!!
        }

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // and set the height for cell:
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messageVC : MessagesViewController?
    // var messageVC = MessagesViewController()
    
    // when tapping at one row: 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        
        let user = self.myFriends[indexPath.row]
        self.messageVC?.showChatControllerForUser(partnerUser: user) // jump to new page
        
    }
    
}





