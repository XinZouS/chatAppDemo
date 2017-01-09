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
    }
    
    var observingTimer = Timer() // for forcing it reload table only once;
    func observeUserMessages(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }

        // make a link reference:
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            // print(snapshot)
            let msgId = snapshot.key // then find this msg:
            let msgRef = FIRDatabase.database().reference().child("messages").child(msgId)
            msgRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                // print(snapshot) // and get msgs into dictionary:
                if let dictionary = snapshot.value as? [String: Any] {
                    let getMsg = Message()
                    getMsg.setValuesForKeys(dictionary)
                    self.messages.append(getMsg)
                    
                    if let chatPartnerId = getMsg.chatPartnerId() {
                        self.messagesDictionary[chatPartnerId] = getMsg
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (m1, m2) -> Bool in
                            return (m1.timeStamp?.intValue)! > (m2.timeStamp?.intValue)!
                        })
                    }
                    self.observingTimer.invalidate()
                    self.observingTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.reloadTable), userInfo: nil, repeats: false)
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    func reloadTable(){
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
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

