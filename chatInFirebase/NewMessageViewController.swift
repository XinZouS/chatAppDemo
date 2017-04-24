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
    
    var messageVC : MessagesViewController? 
    
    var currUser : User?
    
    var myFriends = [User]() {
        didSet {
            tableViewReloadData()
            if myFriends.count > 0 {
                sendNotificationNewRequest(from: myFriends.last!)
            }
        }
    }
    var myRequests = [User]() {
        didSet {
            if myRequests.count < 1 { // ["myRequests", "myFriends"]
                sectionNames = [nameStrOfMyFriends]
            }else{
                sectionNames = [nameStrOfNewRequest, nameStrOfMyFriends]
            }
            tableView.reloadData()
        }
    }
    let nameStrOfNewRequest = "New Friend Requests"
    let nameStrOfMyFriends = "My Friends"
    var sectionNames = ["My Friends"]
    
    let cellId = "cellId"
    let requestCellId = "requestCellId"
    
    let savingKeyForMyFriends = "myFriends"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rb1 = UIBarButtonItem(title: "🔍", style: .plain, target: self, action: #selector(searchFriends))
        // let rb2 = UIBarButtonItem(title: "🔄", style: .plain, target: self, action: #selector(tableViewReloadData))
        navigationItem.rightBarButtonItems = [rb1]
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

        // change tableViewCell at UserCell.class (at bottom of this file)
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.register(UserNewrequestCell.self, forCellReuseIdentifier: requestCellId)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("== viewWillAppear, myFriends.count : ", myFriends.count)
        setupCurrUser()
        fetchMyFriendsOnFirebase()
        fetchMyRequestOnFirebase()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
            if tableView.numberOfSections == 2, indexPath.section == 0 {
                let newFriend = myRequests[indexPath.row]
                rejectRequest(of: newFriend)
                return
            }
            removeContactOnFirebaseAndLocally(of: indexPath.row)
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    // when tapping at one row:
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //dismiss(animated: true, completion: nil)
        if tableView.numberOfSections == 2, indexPath.section == 0 {
            let selectedCell = tableView.cellForRow(at: indexPath) as! UserNewrequestCell
            selectedCell.zoomInProfileImage()
            return
        }
        
        tabBarController?.selectedIndex = 0
        let user = self.myFriends[indexPath.row]
        self.messageVC?.showChatControllerForUser(partnerUser: user)
    }
    
    func removeContactOnFirebaseAndLocally(of friendIndex: Int){
        guard let removeId = myFriends[friendIndex].id, let myId = currUser?.id else { return }
        if removeId == myId {
            showAlertWith(title: "😅Hate yourself?", message: "Learn to love yourself😇. You should keep your contact in friends list.")
            return
        }
        var newList = [String]()
        for oldFriend in myFriends {
            if oldFriend.id == removeId { continue }
            newList.append(oldFriend.id!)
        }
        newList.sort()
        let usersRef = FIRDatabase.database().reference().child("users")
        usersRef.child(myId).child("friends").setValue(newList)
        self.myFriends.remove(at: friendIndex)
    }
    
    
    func tableViewReloadData(){
        DispatchQueue.main.async(execute: {
            print(" - tableViewReloadData() - ")
            self.tableView.reloadData()
        })
    }
    
    func setupCurrUser(){
        if let msgUser = messageVC?.currUser {
            self.currUser = msgUser
            navigationController?.setupNavBarWithUser(user: currUser!, in: self)
        }
    }
    
    /*
    func fetchMyFriendUsersFromFirebase(){
        guard let currId = currUser?.id else { return }
        let usersRef = FIRDatabase.database().reference().child("users")
        usersRef.child(currId).child("friends").observe(.value, with: { (snapshot) in
            //print("--- fetchMyFriendUsersFromFirebase(): snapshot.value: \(snapshot.value)") // [userIds]
            //self.myFriends.removeAll() // BUG: can NOT removeAll here, tableView loading will err: index out of range!!!
            if let friendIds = snapshot.value as? [String] {
                //print("--- get friendIds.count: ", friendIds.count)
                self.myFriends.removeAll()
                for id in friendIds {
                    self.fetchFriendsForCurrUserBy(friendId: id, fromRef: usersRef)
                }
                self.saveMyFriendUsersIntoDisk()
            }else{
                self.fetchMyFriendUsersFromDisk()
            }
        }, withCancel: nil)
        //tableViewReloadData() // with or without this makes no different...
        
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
 */
    func fetchMyFriendsOnFirebase(){
        guard let myId = currUser?.id else { return }
        let frdRef = FIRDatabase.database().reference().child("users").child(myId).child("friends")
        frdRef.observe( .value, with: {(snapshot) in
            print("--- fetchMyFriendsOnFirebase()")
            if let frdDict = snapshot.value as? [String] {
                for friendId in frdDict {
                    self.fetchOneFriendUserBy(id: friendId)
                }
                self.tableViewReloadData()
            }
        })
    }
    func fetchMyRequestOnFirebase(){
        guard let myId = currUser?.id else { return }
        let reqRef = FIRDatabase.database().reference().child("friendRequests").child(myId)
        reqRef.observe(.childAdded, with: {(snapshot)in
            print("get a new request: ", snapshot)
            if let newReqId = snapshot.key as? String, newReqId != "", newReqId != " " {
                self.fetchOneRequestingUserBy(id: newReqId)
            }
        })
        
    }

    
    let userDefaults = UserDefaults.standard
    private func saveMyFriendUsersIntoDisk(){
        if myFriends.count == 0 { return }
        let encodedData : Data = NSKeyedArchiver.archivedData(withRootObject: myFriends)
        print("-- saveMyFriendUsersIntoDisk()()")
        userDefaults.set(encodedData, forKey: savingKeyForMyFriends)
        userDefaults.synchronize()
    }
    func fetchMyFriendUsersFromDisk(){
        if let friendList = currUser?.friends!, friendList.count > 0 {
            if let decodedData = userDefaults.object(forKey: savingKeyForMyFriends) as? Data {
                let decodedItems = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as! [User]
                myFriends = decodedItems
                self.tableViewReloadData()
                print("-- fetchMyFriendUsersFromDisk: ", myFriends)
            }
        }
    }
    func removeMyFriendUsersFromDisk(){
        print("---- removeMyFriendUsersFromDisk() -----")
        messageVC?.removeUserFromDisk()
    }
    
    // for new friend requests button action: 
    func acceptRequest(from newUser: User?){
        print("====== acceptRequest() ======")
        guard let newUser = newUser else { return }
        removeRequestOf(friend: newUser) // BUG: must remove here first, instead of at the end of this func!!!!!!
//        myFriends.removeAll() // no use this; bcz remove only before fetch from firebase
        if myFriends.count != 0 {
            for friend in myFriends {
                if friend.id! == newUser.id! {
                    print("------- already has this friend; return.")
                    return // already has this friend;
                }
            }
        }
        myFriends.append(newUser) // with or without this no different;
        print("---   myFriends.append(newUser).count = ", myFriends.count)
        if let myId: String = currUser?.id, let friendId: String = newUser.id {
            updateFriendsListInFirebaseFor(me: myId, friend: friendId) // add friend to my list
            updateFriendsListInFirebaseFor(me: friendId, friend: myId) // add me to my friend's list
        }
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
        
        ref.child(me).child("friends").observeSingleEvent(of: .value, with: {(snapshot) in
            if var friendsList = snapshot.value as? [String] {
                print("--------- Doing updateFriendsListInFirebaseFor(friend).")
                for oldFriend in friendsList {
                    if friend == oldFriend { return }
                }
                friendsList.append(friend)
                ref.child(me).child("friends").setValue(friendsList)
            }
        })
        
        
    }
    
    func searchFriends(){
        let searchVC = SearchViewController(collectionViewLayout: UICollectionViewFlowLayout())
        searchVC.currUser = self.currUser
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    
    func fetchOneRequestingUserBy(id : String?) {
        guard let id = id, id != "", id != " " else { return }
        FIRDatabase.database().reference().child("users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
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
                print("-- fetchOneRequestingUserBy(id), 111 myRequests.append(), count = ", self.myFriends.count)
            }
            //self.tableViewReloadData() ///// async or sync no different.. and run or not run no different
        })
    }
    func fetchOneFriendUserBy(id : String?) {
        guard let id = id, id != "", id != " " else { return }
        FIRDatabase.database().reference().child("users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            let getId = snapshot.key as String
            var noDuplicate = true
            if self.myFriends.count > 0 {
                for frdUser in self.myFriends {
                    if getId == "\(frdUser.id!)" { noDuplicate = false }
                }
            }
            if let dict = snapshot.value as? [String:AnyObject], noDuplicate {
                let newUser = User(dictionary: dict)
                newUser.id = snapshot.key as String
                self.myFriends.append(newUser)
                print("-- fetchFriendUserBy(id), 222 myFriends.append(), count = ", self.myFriends.count)
            }
        })
    }
    func sendNotificationNewRequest(from newFriend: User){
        guard let newName = newFriend.name, newName != "", let newProfileUrl = newFriend.profileImgURL, newProfileUrl != "" else {return}
        
    }

    
    //=== For Profile image zooming ====================
    private var startFrame : CGRect?
    private var blurEffectView: UIVisualEffectView!
    private var zoomingImgView: UIImageView!
    
    func performZoomInFor(imgView: UIImageView) {
        startFrame = imgView.superview?.convert(imgView.frame, to: nil)
        zoomingImgView = UIImageView(frame: startFrame!)
        zoomingImgView.image = imgView.image
        zoomingImgView.isHidden = false
        zoomingImgView.isUserInteractionEnabled = true
        zoomingImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performZoomOutImage)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light) )
            blurEffectView.isHidden = false
            blurEffectView.frame = self.view.bounds
            blurEffectView.effect = UIBlurEffect(style: .light)
            blurEffectView.alpha = 0
            
            keyWindow.addSubview(blurEffectView)
            keyWindow.addSubview(zoomingImgView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                let newW = keyWindow.frame.width
                let newH = imgView.frame.height / imgView.frame.width * newW
                self.zoomingImgView.frame = CGRect(x: 0, y: 0, width: newW, height: newH)
                self.zoomingImgView.center = keyWindow.center
                self.blurEffectView.alpha = 1
            }, completion: nil)
        }
    }
    func performZoomOutImage(){
        zoomingImgView.layer.cornerRadius = 60
        zoomingImgView.layer.masksToBounds = true
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
            self.zoomingImgView.frame = self.startFrame!
            self.blurEffectView.alpha = 0
        }) { (completed: Bool) in
            self.blurEffectView.isHidden = true
            self.zoomingImgView.isHidden = true
        }
    }
    
    
    func showAlertWith(title:String, message:String){
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alertCtrl.dismiss(animated: true, completion: nil)
        }))
        self.present(alertCtrl, animated: true, completion: nil)
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}





