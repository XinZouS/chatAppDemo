//
//  ViewController.swift
//  chatInFirebase
//
//  Created by Xin Zou on 12/29/16.
//  Copyright © 2016 Xin Zou. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class MessagesViewController: UITableViewController {
    
    var newMsgVC : NewMessageViewController?
    var profileVC: ProfileViewController?

    let cellId = "cellId"
    
    var currUser = User(){
        didSet {
            setupNavBarWithUser(user: currUser)
        }
    }
    
    var messages = [Message]()  // sorted by timeStamp for tableView
    var messageOfPartnerId = [String:Message]() // dict[chatPartnerId] for latest msgs;
    
    let tabBarItemChat: UITabBarItem = {
        let c = UITabBarItem()
        c.image = UIImage(named: "playButton_w")
        return c
    }()
    
    let tabBar : UITabBar = {
        let t = UITabBar()
        
        return t
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(handleLogout))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addNewMessage))
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true // allow delete at row;
        
        checkIfUserIsLogin()
        
        // observeUserMessages() // move to func setupNavBarWithUser()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let user = fetchUserFromDisk() {
            currUser = user
            navigationController?.setupNavBarWithUser(user: currUser, in: self)
        }
        //remove all notifications:
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        // bcz tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let msg = messages[indexPath.row]
        cell.message = msg
        cell.layer.shouldRasterize = true // 2 lines for better image loading
        cell.layer.rasterizationScale = UIScreen.main.scale
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let msg = messages[indexPath.row] // get the latest msg
        guard let chartPartnerId = msg.chatPartnerId() else {
            return
        }
        let ref = FIRDatabase.database().reference().child("users").child(chartPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            // get the partner as a new user:
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let partnerUser = User()
            partnerUser.id = chartPartnerId
            partnerUser.setValuesForKeys(dictionary)
            
            self.showChatControllerForUser(partnerUser: partnerUser)
            
        }, withCancel: nil)
    }
        
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let myId = FIRAuth.auth()?.currentUser?.uid else {return}
        let msg = messages[indexPath.row]
        guard let partnerId = msg.chatPartnerId() else {return}
        
        deleteMessageInDataBaseFor(partnerId: partnerId, myId: myId)

        // do it in deleteMessageInDataBaseFor(..): DispatchQueue.main.async{}
//        FIRDatabase.database().reference().child("user-messages").child(myId).child(partnerId).removeValue { (err, ref) in
//            if err != nil {
//                print("get error when deleting msg : MessagesViewController.swift: editingStyle(): ", err)
//                return
//            }
//            self.deleteMessageLocallyFor(partnerId: partnerId)
//        }
    }
    
    
    func checkIfUserIsLogin(){
        print(" - 1. checkIfUserIsLogin(): ")
        if let getuser = fetchUserFromDisk() { // setup currUser;
            currUser = getuser
            print(" - 2. getUser: \(currUser.name), img: \(currUser.profileImgURL)")
        }
        if let uid = FIRAuth.auth()?.currentUser?.uid, uid != "", let curId = currUser.id, curId != "" {
            // get user by id in firebase:
            fetchUserAndSetUpNavBarTitle()
        }else{
            // handleLogout()  //but we use a better way to call that func:
            performSelector(inBackground: #selector(handleLogout), with: nil)
        }
    }
    
    func fetchUserAndSetUpNavBarTitle() {
        print(" -- 3.0 fetchUserAndSetUpNavBarTitle(), ")
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        if let getuser = fetchUserFromDisk(){
            print(" -- 3.1 first try fetchUserFromDisk(): getuser=\(getuser)")
            currUser = getuser
            setupNavBarWithUser(user: currUser)
        }
        // get current user by id in database:
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print(" -- 3.2 get connect to FIRAuth, load currUser:")
            // get snapshot is a JSON obj, so unwap it to get info:
            if let dictionary = snapshot.value as? [String:Any] {
                self.currUser.setValuesForKeys(dictionary) // profileImgURL, name, email (already has id,friends)
                self.setupNavBarWithUser(user: self.currUser)
                self.saveUserIntoDisk()
            }
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(user: User) {
        //        messages.removeAll()
        //        messageOfPartnerId.removeAll()
        //        tableView.reloadData()
        //
        navigationController?.setupNavBarWithUser(user: user, in: self) // in
        
        observeUserMessages() // fetch msgs ONLY for current user;
        
        // titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        
    }
    
    
    
    func deleteMessageInDataBaseFor(partnerId: String, myId: String){
        let msgsRef = FIRDatabase.database().reference().child("user-messages").child(myId).child(partnerId)
        msgsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot) // == partnerId:[msgIds]
            guard let msgsDictionary = snapshot.value as? [String: AnyObject] else {return}

            let findMsgRef = FIRDatabase.database().reference().child("messages")
            
            for (key, val) in msgsDictionary {
                //print("get key: --- ",key) // == key of each messages;
                findMsgRef.child(key).observeSingleEvent(of: .value, with: { (snapshotMsg) in
                    //print("get message snapshot: ", snapshotMsg) // == msgKey:{String:AnyObj}
                    
                    guard var getMsg = snapshotMsg.value as? [String: AnyObject],
                          let isDeletedOnce = getMsg["isDeletedByPartner"] as? Bool else {return}
                    //print("get msg deletionCount = ", cnt) // == value of count;
                    if isDeletedOnce {
                        // delete the msg data in DB;
                        if let imgUrl = getMsg["imgURL"] as? String, let fileName = getMsg["fileName"] as? String {
                            self.deleteFileInFireBaseAt(folder: "message_image", fileName: fileName)
                        }
                        if let videoUrl = getMsg["videoURL"] as? String, let fileName = getMsg["fileName"] as? String {
                            self.deleteFileInFireBaseAt(folder: "message_video", fileName: fileName)
                        }
                        findMsgRef.child(key).removeValue()

                    }else{
                        getMsg["isDeletedByPartner"] = true as AnyObject?
                        findMsgRef.child(key).updateChildValues(getMsg)
                    }
                    
                    msgsRef.removeValue { (err, ref) in
                        if err != nil {
                            print("get error when deleting msg : MessagesViewController.swift: editingStyle(): ", err)
                            return
                        }
                        self.deleteMessageLocallyFor(partnerId: partnerId)
                    }
                    
                }, withCancel: nil)
            }
            
        }, withCancel: nil)
        
    }
    
    // one way to delete message, but not so save, bcz db may delay:---------
    //private func deleteMessageAt(indexPath: IndexPath){
        //self.messages.remove(at: indexPath.row)
        //self.tableView.deleteRows(at: [indexPath], with: .automatic)
    //}
    // the other way to delete message, remove reference from db:------------
    private func deleteMessageLocallyFor(partnerId: String){
        messageOfPartnerId.removeValue(forKey: partnerId)
        for idx in 0...messages.count - 1 {
            let msg = messages[idx]
            if msg.chatPartnerId() == partnerId {
                messages.remove(at: idx)
                return
            }
        }        
        reloadAndSortTable()
    }
    private func deleteFileInFireBaseAt(folder:String, fileName:String){
        if folder.compare("message_image") != ComparisonResult.orderedSame && folder.compare("message_video") != ComparisonResult.orderedSame {
            print("error: cannnot find folder name [\(folder)] in FireBase storage, MessagesViewController.deleteFileInFireBaseAt()")
            return
        }
        let ref = FIRStorage.storage().reference().child(folder).child(fileName)
        ref.delete { (err) in
            if err != nil {
                print("get error when try to delete file [\(fileName)]: ", err)
                return
            }
            // print("fild deleted!!")
        }
    }
    
    
    private func observeUserMessages(){
        guard let myid = FIRAuth.auth()?.currentUser?.uid else { return }
        self.currUser.id = myid

        // get current user ID:
        let ref = FIRDatabase.database().reference().child("user-messages").child(myid)
        fetchMessageFromDisk()

        // observe for new messages:------------------
        ref.observe(.childAdded, with: { (snapshot) in
            
            // print(snapshot) // == partnerId {msgId}
            let partnerId = snapshot.key
            let partnerRef = FIRDatabase.database().reference().child("user-messages").child(myid).child(partnerId)
            partnerRef.observe(.childAdded, with: { (snapshot) in
                
                //print(snapshot) // == added msgId s {1}
                let msgId = snapshot.key // then find this msg:
                self.fetchMessageWithMessageID(messageId: msgId)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        // also if the message been removed(delete) in db already:--------
        ref.observe(.childRemoved, with: { (snapshot) in
            self.deleteMessageLocallyFor(partnerId: snapshot.key)
        }, withCancel: nil)
    }
    func reloadAndSortTable(){
        self.messages = Array(self.messageOfPartnerId.values)
        self.messages.sort(by: { (m1, m2) -> Bool in
            return (m1.timeStamp?.intValue)! > (m2.timeStamp?.intValue)!
        })
        saveMessageToDisk()
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            if let getMsg = self.messages.first {
                let indexpath = IndexPath(row: 0, section: 0)
                let topCell = self.tableView.cellForRow(at: indexpath) as? UserCell
                let latestSenderName = topCell?.textLabel?.text ?? "my friend"
                //print("---- get name: ", latestSenderName, ", topCell=", topCell, ", all cells=", self.tableView.visibleCells)
                self.newMsgNotification(newMsg: getMsg, senderName: latestSenderName)
            }
        })
    }
    var observingTimer = Timer() // for forcing it reload table only once while loading messages;
    private func fetchMessageWithMessageID(messageId:String) {
        let msgRef = FIRDatabase.database().reference().child("messages").child(messageId)
        msgRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // print(snapshot) // == get msgs into dictionary:
            if let dictionary = snapshot.value as? [String: Any] {
                let getMsg = Message(dictionary: dictionary)
                //let getMsg = Message() // replaced by one line above;
                //getMsg.setValuesForKeys(dictionary)
//                self.messages.append(getMsg)
                
                if let chatPartnerId = getMsg.chatPartnerId() {
                    self.messages.append(getMsg)
                    self.messageOfPartnerId[chatPartnerId] = getMsg // sorting move to reloadTable();
                }
                self.observingTimer.invalidate()
                self.observingTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.reloadAndSortTable), userInfo: nil, repeats: false)
            }
            
        }, withCancel: nil)

    }
    private func saveMessageToDisk(){
        if let currName = self.currUser.name, let currId = self.currUser.id {
            let userDefaults = UserDefaults.standard
            let encodedData : Data = NSKeyedArchiver.archivedData(withRootObject: self.messages)
            userDefaults.set(encodedData, forKey: "\(currName)\(currId)Messages")
            userDefaults.synchronize()
            print("- save messages to disk success!!")
        }
    }
    private func fetchMessageFromDisk(){
        // load Messages from disk:
        if let currName = self.currUser.name, let currId = self.currUser.id,
            let decodedData = UserDefaults.standard.object(forKey: "\(currName)\(currId)Messages") as? Data {
            let decodedMessages = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as! [Message]
            self.messages = decodedMessages
            print(" - 4.0 fetchMessageFromDisk() success: self.messages.count = ", self.messages.count)
        }else{
            print("======= can NOT to load messages from disk: for userName,id = ", currUser.name, currUser.id )
        }
    }
    private func removeMessageFromDisk(){
        if let currName = self.currUser.name, let currId = self.currUser.id {
            UserDefaults.standard.removeObject(forKey: "\(currName)\(currId)Messages")
            print("------ removed messages in disk success!!")
        }
    }
    func saveUserIntoDisk(){
        if self.currUser.name != nil, self.currUser.id != nil, self.currUser.profileImgURL != nil {
            let userDefaults = UserDefaults.standard
            let encodedData : Data = NSKeyedArchiver.archivedData(withRootObject: self.currUser)
            userDefaults.set(encodedData, forKey: "currUser")
            userDefaults.synchronize()
            print("---- save currUser to disk success!!")
        }
    }
    func fetchUserFromDisk() -> User? {
        if let decodedData = UserDefaults.standard.object(forKey: "currUser") as? Data {
            let decodedUser = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as! User
            return decodedUser
            print("------ load currUser success")
        }
        return nil as User?
    }
    func removeUserFromDisk(){
        UserDefaults.standard.removeObject(forKey: "currUser")
        UserDefaults.standard.removeObject(forKey: "myFriends")
        print("-------- 2. removed user and myFriends list success. ")
    }
    private func newMsgNotification(newMsg: Message, senderName: String){
        guard let newText = newMsg.text, let senderId = newMsg.fromId else { return }
        // push notifications for new msg coming;
        let content = UNMutableNotificationContent()
        content.title = "New Message"
        content.subtitle = "From \(senderName): "
        content.body = newText
        content.badge = 1
        content.sound = UNNotificationSound.default()
        updateBadgeNumberBy(increment: 1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: newMessageNotificationIdStr, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (err) in
            if let err = err {
                print("get error when firing UNUserNotification; MessagesVC.swift:newMsgNotification --->", err)
            }
        })
    }
    private func updateBadgeNumberBy(increment: Int){
        let currentNumber = UIApplication.shared.applicationIconBadgeNumber
        let newBadgeNumber = currentNumber + increment
        if newBadgeNumber > 0 {//-1 {
            UIApplication.shared.applicationIconBadgeNumber = newBadgeNumber
        }
    }
    
    func showChatControllerForUser(partnerUser: User) { //--- go to ChatLogViewController.swift ---
        let chatLogVC = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogVC.messagesVC = self
        chatLogVC.partnerUser = partnerUser
        chatLogVC.currUser = self.currUser
        
        navigationController?.pushViewController(chatLogVC, animated: true) // equals to use segue() in storyboard;
    }
    
    func handleLogout() { // go to the Login page
        do {
            try FIRAuth.auth()?.signOut()
        }catch let signoutErr {
            print("error when signOut: \(signoutErr)")
            return
        }
        self.messages.removeAll()
        self.messageOfPartnerId.removeAll()
        self.removeUserFromDisk()
        self.removeMessageFromDisk()
        self.navigationItem.title = "New user"
        self.newMsgVC?.myFriends.removeAll()
        self.newMsgVC?.myRequests.removeAll()
        
        let loginVC = LoginViewController()
        loginVC.messagesViewController = self // for setting bar.title;
        UserDefaults.standard.set(false, forKey: loginVC.acceptedEULAKey)
        present(loginVC, animated: true, completion: nil) // this need to be dismiss when its done!
    }
    
    func addNewMessage(){ // go to NewMessageViewController
        let newMsgVC = NewMessageViewController()
        newMsgVC.messageVC = self // need reference in newMsgVC
        newMsgVC.currUser = self.currUser
        let navVC = UINavigationController(rootViewController: newMsgVC)
        present(navVC, animated: true, completion: nil)
    }


}
