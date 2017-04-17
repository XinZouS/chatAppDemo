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
    
    var currUser : User?
    var myFriends = [User]()
    var myRequests = [User]() {
        didSet {
            if myRequests.count < 1 { // ["myRequests", "myFriends"]
                sectionNames = [nameStrOfMyFriends]
            }else{
                sectionNames = [nameStrOfNewRequest, nameStrOfMyFriends]
            }
            tableViewReloadData()
        }
    }
    let nameStrOfNewRequest = "New Friend Requests"
    let nameStrOfMyFriends = "My Friends"
    var sectionNames = ["My Friends"]
    
    let cellId = "cellId"
    let requestCellId = "requestCellId"
    
    let savingKeyForMyFriends = "myFriends"

    var messageVC : MessagesViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "🔍", style: .plain, target: self, action: #selector(searchFriends))
        let rb1 = UIBarButtonItem(title: "🔍", style: .plain, target: self, action: #selector(searchFriends))
        // let rb2 = UIBarButtonItem(title: "🔄", style: .plain, target: self, action: #selector(tableViewReloadData))
        navigationItem.rightBarButtonItems = [rb1]
        //navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelNewMessage))
        setupCurrUser()
        
        // change tableViewCell at UserCell.class (at bottom of this file)
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.register(UserNewrequestCell.self, forCellReuseIdentifier: requestCellId)

        fetchMyFriendUsersFromFirebase()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchMyFriendRequests() // from Firebase

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        myRequests.removeAll()
        saveMyFriendUsersIntoDisk()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNames.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectionNames.count {
        case 1:
            return myFriends.count
        case 2:
            return section == 0 ? myRequests.count : myFriends.count
        default:
            return myFriends.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section >= sectionNames.count { return "No name section" }
        return sectionNames[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var user : User?
        var cell : UserCell?
        if sectionNames.count > 1, indexPath.section == 0 {
            user = myRequests[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: requestCellId, for: indexPath) as! UserNewrequestCell
        }else{
            user = myFriends[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        }
        cell?.user = user
        cell?.newMsgVC = self
        cell?.textLabel?.text = user?.name!
        cell?.detailTextLabel?.text = user?.email!
        
        if let profileImgURL = user?.profileImgURL {
            //--- better way to load img -----------------------------------------
            cell?.profileImageView.loadImageUsingCacheWith(urlString: profileImgURL)
            
            //--- too much download way, replaced by above -----------------------
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
        return cell!
    }
    
    // support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    // when tapping at one row:
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //dismiss(animated: true, completion: nil)
        tabBarController?.selectedIndex = 0
        
        let user = self.myFriends[indexPath.row]
        self.messageVC?.showChatControllerForUser(partnerUser: user) // jump to new page
        
    }
    
    
    func tableViewReloadData(){
//        if myRequests.count < 1 { // ["myRequests", "myFriends"]
//            sectionNames = [nameStrOfMyFriends]
//        }else{
//            sectionNames = [nameStrOfNewRequest, nameStrOfMyFriends]
//        }
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func setupCurrUser(){
        if let getUser = messageVC?.fetchUserFromDisk() {
            currUser = getUser
//            setupNavBarWithUser(user: getUser)
            navigationController?.setupNavBarWithUser(user: getUser, in: self)
        }
    }

    
    func fetchMyFriendUsersFromFirebase(){
        guard let currId = currUser?.id else { return }
        let usersRef = FIRDatabase.database().reference().child("users")
        usersRef.child(currId).child("friends").observe(.value, with: { (snapshot) in
            //print("--- fetchMyFriendUsersFromFirebase(): snapshot.value: \(snapshot.value)") // [userIds]
            if let friendIds = snapshot.value as? [String] {
                //print("--- get friendIds.count: ", friendIds.count)
                for id in friendIds {
                    self.fetchFriendsForCurrUserBy(friendId: id, fromRef: usersRef)
                }
                self.saveMyFriendUsersIntoDisk()
            }else{
                self.fetchMyFriendUsersFromDisk()
            }
        }, withCancel: nil)
        
//        //DEMO: get ALL users from firebase;
//        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
//            //print(snapshot)  // JSON data of users, one by one, use array to load all users:
//            if let dictionary = snapshot.value as? [String:AnyObject] {
//                let user = User()
//                user.id = snapshot.key
//                // if using this way, the class properties MUST match the exactly structure with data in Firebase, or it will crash!
//                // aka : user.name = dictionary["name"]
//                user.setValuesForKeys(dictionary)
//                self.myFriends.append(user)
//                // print("get user name: \(user.name) and email: \(user.email)")
//                
//                // to avoid crash, use dispatch_async to load users into table:
//                DispatchQueue.main.async(execute: {
//                    self.tableView.reloadData()
//                })
//            }
//        }, withCancel: nil)
        
    }
    func fetchFriendsForCurrUserBy(friendId: String?, fromRef: FIRDatabaseReference?){
        guard let id = friendId, id != "", id != " ", let ref = fromRef else { return }
        myFriends.removeAll()
        ref.child(id).observe(.value, with: { (snapshot) in
            //print("-- fetchFriendsForCurrUserBy(): snapshot: ", snapshot) // (id){User obj}
            if let dictionary = snapshot.value as? [String:AnyObject] { // User()
                let user = User()
                user.id = snapshot.key
                user.setValuesForKeys(dictionary)
                self.myFriends.append(user)
                self.tableViewReloadData()
            }
        }, withCancel: nil)
    }
    
    let userDefaults = UserDefaults.standard
    
    private func saveMyFriendUsersIntoDisk(){
        if myFriends.count == 0 { return }
        let encodedData : Data = NSKeyedArchiver.archivedData(withRootObject: myFriends)
        userDefaults.set(encodedData, forKey: savingKeyForMyFriends)
        userDefaults.synchronize()
    }
    func fetchMyFriendUsersFromDisk(){
        if let friendList = currUser?.friends!, friendList.count > 0 {
            if let decodedData = userDefaults.object(forKey: savingKeyForMyFriends) as? Data {
                let decodedItems = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as! [User]
                myFriends = decodedItems
                self.tableViewReloadData()
                print("get saved Friends: ", myFriends)
            }
        }
    }
    func removeMyFriendUsersFromDisk(){
        messageVC?.removeUserFromDisk()
    }
    
    func fetchMyFriendRequests(){
        guard let myId = currUser?.id else {
            print("did not get currUser id in NewMessageViewController.swift:fetchMyFriendRequests()", currUser?.id)
            return
        }
        let ref = FIRDatabase.database().reference()
        ref.child("friendRequests").child(myId).observeSingleEvent(of: .value, with: { (snapshot) in
            print("--- get new friend request: NewMessageViewController.swift: snapshot == ", snapshot)
            if let requestDict = snapshot.value as? [String:Bool], requestDict.count > 0  {
                self.myRequests.removeAll()
                for req in requestDict {
                    if let friendId = req.key as? String, friendId != "" {
                        print("--- get request id: ", friendId)
                        self.fetchRequestingUserBy(id: friendId)
                        if self.sectionNames.count == 1 {
                            self.sectionNames.insert(self.nameStrOfNewRequest, at: 0)
                        }
                        print("---- find num of user: ", self.myRequests.count)
                    }
                }
            }else{
                self.sectionNames = [self.nameStrOfMyFriends]
            }
        })
        self.tableViewReloadData()
    }
    
    // for new friend requests button action: 
    func acceptRequest(from newUser: User?){
        print("====== acceptRequest() ======")
        guard let newUser = newUser else { return }
        removeRequestOf(friend: newUser) // BUG: must remove here first, instead of at the end of this func!!!!!!
        if myFriends.count != 0 {
            for friend in myFriends {
                if friend.id! == newUser.id! {
                    print("------- already has this friend; removeRequestFrom().")
                    removeRequestOf(friend: newUser)
                    return // already has this friend;
                }
            }
        }
        myFriends.append(newUser)
        print("---   myFriends.append(newUser).count = ", myFriends.count)
        if let myId: String = currUser?.id, let friendId: String = newUser.id {
            updateFriendsListInFirebaseFor(me: myId, friend: friendId) // add friend to my list
            updateFriendsListInFirebaseFor(me: friendId, friend: myId) // add me to my friend's list
        }
        //saveMyFriendUsersIntoDisk()
        fetchMyFriendRequests()
    }
    func rejectRequest(of newUser: User?){
        guard let newUser = newUser else { return }
        removeRequestOf(friend: newUser)
    }
    
    private func removeRequestOf(friend: User){
        guard let idx = myRequests.index(of: friend) else { return }
        myRequests.remove(at: idx )
        print("- WILL removeRequestOf(friend), myRequests.count = ", myRequests.count)
        self.tableViewReloadData()
        // also remove from firebase:
        if let myId: String = currUser?.id, let friendId: String = friend.id {
            let ref = FIRDatabase.database().reference()
            print("- remove request in Firebase:.child(friendId).removeValue()")
            ref.child("friendRequests").child(myId).child(friendId).removeValue()
            print("- AFTER removeRequestOf(friend), myRequests.count = ", myRequests.count)
        }
    }
    private func updateFriendsListInFirebaseFor(me: String, friend: String){
        let ref = FIRDatabase.database().reference().child("users")
        print("--------- WILL updateFriendsListInFirebaseFor(friend).")
        ref.child(me).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:AnyObject] {
                print("--------- Doing updateFriendsListInFirebaseFor(friend).")
                let getUser = User(dictionary: dict)
                var myList = getUser.friends!
                if myList.count != 0 {
                    for oldFriend in myList {
                        if oldFriend == friend { return }
                    }
                }
                myList.append(friend)
                let newValues = ["friends" : myList] as [String : Any]
                ref.child(me).updateChildValues(newValues)
            }
        }, withCancel: { (err) in
            print("!!! get error when updateFriendsListInFirebaseFor() in NewMessageViewController.swift: ", err)
        })
        
    }
    
    func searchFriends(){
        let searchVC = SearchViewController(collectionViewLayout: UICollectionViewFlowLayout())
        searchVC.currUser = self.currUser
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    func fetchRequestingUserBy(id:String) {
        FIRDatabase.database().reference().child("users").child(id).observe(.value, with: { (snapshot) in
            let getId = snapshot.key as String
            var noDuplicate = true
            if self.myRequests.count > 0 {
                print("1. noDuplicate = ", noDuplicate)
                for reqUser in self.myRequests {
                    if getId == "\(reqUser.id!)" { noDuplicate = false }
                }
            }
            if let dict = snapshot.value as? [String:AnyObject], noDuplicate {
                let newUser = User(dictionary: dict)
                newUser.id = snapshot.key as String
                self.myRequests.append(newUser)
//                if self.sectionNames.count == 1 {
//                    self.sectionNames.insert(self.nameStrOfNewRequest, at: 0)
//                }
            }
            self.tableViewReloadData()
        })
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}





