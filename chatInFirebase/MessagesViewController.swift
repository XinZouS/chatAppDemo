//
//  ViewController.swift
//  chatInFirebase
//
//  Created by Xin Zou on 12/29/16.
//  Copyright © 2016 Xin Zou. All rights reserved.
//

import UIKit
import Firebase

// change the main VC into TableViewController:
class MessagesViewController: UITableViewController {
    

    let cellId = "cellId"
    
    var currUser = User()
    
    var messages = [Message]()
    var messagesDictionary = [String:Message]()
    
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
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //print("selecting at : ", indexPath.row) // delete this partner and all msgs in databas:
        guard let myId = FIRAuth.auth()?.currentUser?.uid else {return}
        let msg = messages[indexPath.row]
        guard let partnerId = msg.chatPartnerId() else {return}
        
        FIRDatabase.database().reference().child("user-messages").child(myId).child(partnerId).removeValue { (err, ref) in
            if err != nil {
                print("get error when deleting msg : MessagesViewController.swift:50", err)
            }
            //self.deleteMessageAt(indexPath: indexPath, forPartnerId: partnerId)
            self.deleteMessageFor(partnerId: partnerId)
        }
    }
    // one way to delete message, but not so save:
//    private func deleteMessageAt(indexPath: IndexPath){
//        self.messages.remove(at: indexPath.row)
//        self.tableView.deleteRows(at: [indexPath], with: .automatic)
//    }
    // the other way to delete message:
    private func deleteMessageFor(partnerId: String){
        messagesDictionary.removeValue(forKey: partnerId)
        reloadTable()
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
        
        // also if the message been removed(delete):--------
        ref.observe(.childRemoved, with: { (snapshot) in
            //print(snapshot.key) // == the key of message in msgDict,
            //print(self.messagesDictionary) // == all messages got in DB;
            //self.messagesDictionary.removeValue(forKey: snapshot.key)
            //self.reloadTable()
            self.deleteMessageFor(partnerId: snapshot.key)
            
        }, withCancel: nil)
    }
    func reloadTable(){
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (m1, m2) -> Bool in
            return (m1.timeStamp?.intValue)! > (m2.timeStamp?.intValue)!
        })
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    private func fetchMessageWithMessageID(messageId:String){
        let msgRef = FIRDatabase.database().reference().child("messages").child(messageId)
        msgRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // print(snapshot) // == get msgs into dictionary:
            if let dictionary = snapshot.value as? [String: Any] {
                let getMsg = Message(dictionary: dictionary)
                //let getMsg = Message() // replaced by one line above;
                //getMsg.setValuesForKeys(dictionary)
                self.messages.append(getMsg) // do we need this line ?????????????????????
                
                if let chatPartnerId = getMsg.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = getMsg
                    // sorting move to reloadTable();
                }
                self.observingTimer.invalidate()
                self.observingTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.reloadTable), userInfo: nil, repeats: false)
            }
            
        }, withCancel: nil)

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
    
    func showChatControllerForUser(partnerUser: User) { //--- go to chatLogViewController -------------------
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
    
    func addNewMessage(){
        var newMsgVC = NewMessageViewController()
        newMsgVC.messageVC = self // need reference in newMsgVC
        let navVC = UINavigationController(rootViewController: newMsgVC)
        present(navVC, animated: true, completion: nil)
    }


}

