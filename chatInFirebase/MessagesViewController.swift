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
    

    let cellId = "cellId"
    
    var currUser = User()
    
    var messages = [Message]()
    var messagesDictionary = [String:Message]() // dict[chatPartnerId] for latest msgs;
    
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

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addNewMessage))
        
//        use this after user sign in successfully:
//        let ref = FIRDatabase.database().reference(fromURL: "https://chatdemo-4eb7c.firebaseio.com/")
//        ref.updateChildValues(["Key" : "value"])
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        checkIfUserIsLogin()
        
        // observeUserMessages() // move to func setupNavBarWithUser()
        
        tableView.allowsMultipleSelectionDuringEditing = true // allow delete at row, then follow by:
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // remove notification badge number:
        if UIApplication.shared.applicationIconBadgeNumber > 0 {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }        
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //print("selecting at : ", indexPath.row) // delete this partner and all msgs in databas:
        guard let myId = FIRAuth.auth()?.currentUser?.uid else {return}
        let msg = messages[indexPath.row]
        guard let partnerId = msg.chatPartnerId() else {return}
        
        deleteMessageInDataBaseFor(partnerId: partnerId, myId: myId)

        // do it in deleteMessageInDataBaseFor(..): DispatchQueue.main.async{}
        FIRDatabase.database().reference().child("user-messages").child(myId).child(partnerId).removeValue { (err, ref) in
            if err != nil {
                print("get error when deleting msg : MessagesViewController.swift:50", err!)
                return
            }
            //print("deleting message success: key:\(ref.key), value: \(ref)") // ref.key == chatPartnerId;
            //self.deleteMessageAt(indexPath: indexPath, forPartnerId: partnerId)
            self.deleteMessageLocallyFor(partnerId: partnerId)
        }
    }
    private func deleteMessageInDataBaseFor(partnerId: String, myId: String){
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
                        // delete the msg in DB;
                        if let imgUrl = getMsg["imgURL"] as? String, let fileName = getMsg["fileName"] as? String {
                            // delete image in storage
                            self.deleteFileInFireBaseAt(folder: "message_image", fileName: fileName)
                        }
                        if let videoUrl = getMsg["videoURL"] as? String, let fileName = getMsg["fileName"] as? String {
                            // delete video in storage
                            self.deleteFileInFireBaseAt(folder: "message_video", fileName: fileName)
                        }
                        
                        findMsgRef.child(key).removeValue()

                    }else{
                        getMsg["isDeletedByPartner"] = true as AnyObject?
                        findMsgRef.child(key).updateChildValues(getMsg)
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
        messagesDictionary.removeValue(forKey: partnerId)
        reloadTable()
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
    
    
    var observingTimer = Timer() // for forcing it reload table only once;
    func observeUserMessages(){
        guard let myid = FIRAuth.auth()?.currentUser?.uid else {return}

        // get current user ID:
        let ref = FIRDatabase.database().reference().child("user-messages").child(myid)
        // observe for new messages:------------------
        ref.observe(.childAdded, with: { (snapshot) in
            
            // print(snapshot) // == partnerId {msgId}
            let partnerId = snapshot.key
            let partnerRef = FIRDatabase.database().reference().child("user-messages").child(myid).child(partnerId)
            partnerRef.observe(.childAdded, with: { (snapshot) in
                
                //print(snapshot) // == msgId s {1}
                let msgId = snapshot.key // then find this msg:
                self.fetchMessageWithMessageID(messageId: msgId)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        // also if the message been removed(delete) in db already:--------
        ref.observe(.childRemoved, with: { (snapshot) in
            //print(snapshot.key) // == the key of message in msgDict,
            //print(self.messagesDictionary) // == all messages got in DB;
            //self.messagesDictionary.removeValue(forKey: snapshot.key)
            //self.reloadTable()
            self.deleteMessageLocallyFor(partnerId: snapshot.key)
            
        }, withCancel: nil)
    }
    func reloadTable(){
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (m1, m2) -> Bool in
            return (m1.timeStamp?.intValue)! > (m2.timeStamp?.intValue)!
        })
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            if let getMsg = self.messages.first {
                self.newMsgNotification(newMsg: getMsg)
            }
        })
    }
    private func fetchMessageWithMessageID(messageId:String) {
        let msgRef = FIRDatabase.database().reference().child("messages").child(messageId)
        msgRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // print(snapshot) // == get msgs into dictionary:
            if let dictionary = snapshot.value as? [String: Any] {
                let getMsg = Message(dictionary: dictionary)
                //let getMsg = Message() // replaced by one line above;
                //getMsg.setValuesForKeys(dictionary)
                self.messages.append(getMsg)
                
                if let chatPartnerId = getMsg.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = getMsg
                    // sorting move to reloadTable();
                }
                self.observingTimer.invalidate()
                self.observingTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.reloadTable), userInfo: nil, repeats: false)
            }
            
        }, withCancel: nil)

    }
    private func newMsgNotification(newMsg: Message){
        guard let newText = newMsg.text,
              let senderName = messagesDictionary[newMsg.fromId!] else { return }
//        how to get the name of sender??? add sender name into message!
        // push notifications for new msg coming;
        let content = UNMutableNotificationContent()
        content.title = "New Message"
        content.subtitle = newMsg.fromId!
        content.body = newText
        content.badge = 1
        updateBadgeNumberBy(increment: 1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let id = "identifiterNotification"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (err) in
            if let err = err {
                print("get error when firing UNUserNotification; MessagesVC.swift:170 --->", err)
            }
        })
    }
    private func updateBadgeNumberBy(increment: Int){
        let currentNumber = UIApplication.shared.applicationIconBadgeNumber
        let newBadgeNumber = currentNumber + increment
        if newBadgeNumber > -1 {
            UIApplication.shared.applicationIconBadgeNumber = newBadgeNumber
        }
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
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let msg = messages[indexPath.row] 
        guard let chartPartnerId = msg.chatPartnerId() else {
            return
        } // initializer for conditional binding must have optional type, not string
        let ref = FIRDatabase.database().reference().child("users").child(chartPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            // get the partner as a new user: 
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let user = User()
            user.id = chartPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(partnerUser: user)

        }, withCancel: nil)
    }
    
    
    func checkIfUserIsLogin(){
        let uid = FIRAuth.auth()?.currentUser?.uid
        if uid == nil {
            // handleLogout()  //but we use a better way to call that func:
            performSelector(inBackground: #selector(handleLogout), with: nil)
        }else{
            // get user by id in database:
            fetchUserAndSetUpNavBarTitle()
        }
    }
    
    func fetchUserAndSetUpNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { // already unwap uid !!!
            return
        }
        
        // get current user by id in database:
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

            // get snapshot is a JSON obj, so unwap it to get info:
            if let dictionary = snapshot.value as? [String:Any] {
                // self.navigationItem.title = dictionary["name"] as? String // do it in setupNavBarWithUser()
                // set user img on navBar.title: 
                //self.currUser = User()
                self.currUser.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: self.currUser)
            }
        }, withCancel: nil)
        
    }
    
    func setupNavBarWithUser(user: User) {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages() // fetch msgs for ONLY current user; 
        
        
        // self.navigationItem.title = user.name // but this can only set name, we need img using:
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 210, height: 40)
        
        let containerView = UIView() // for adjuse titleLabel when it is too loooong
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        if let profileImageUrl = user.profileImgURL {
            profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
        }
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        containerView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 9).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        // titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))

    }
    
    func showChatControllerForUser(partnerUser: User) { //--- go to ChatLogViewController.swift ---
        let chatLogVC = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogVC.partnerUser = partnerUser
        // get selfUser info and passing object to ChatLogController:
        chatLogVC.currUser = self.currUser
        
        navigationController?.pushViewController(chatLogVC, animated: true) // equals to use segue() in storyboard;
    }
    
    func handleLogout() { // go to the Login page
        do {
            try FIRAuth.auth()?.signOut()
        }catch let signoutErr {
            print("error when signOut: \(signoutErr)")
        }
        self.navigationItem.title = "New user"
        let loginVC = LoginViewController()
        loginVC.messagesViewController = self // for setting bar.title;
        present(loginVC, animated: true, completion: nil) // this need to be dismiss when its done!
    }
    
    func addNewMessage(){ // go to NewMessageViewController
        var newMsgVC = NewMessageViewController()
        newMsgVC.messageVC = self // need reference in newMsgVC
        let navVC = UINavigationController(rootViewController: newMsgVC)
        present(navVC, animated: true, completion: nil)
    }


}


