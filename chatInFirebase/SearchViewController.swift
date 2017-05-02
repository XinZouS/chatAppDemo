//
//  SearchViewController.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/19/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit
import Firebase

// init from NewMessageViewController.swift
class SearchViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var currUser : User?
    var candidateFriends = [User]()
    
    lazy var inputContainerView : BaseInputContainerView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        let c = BaseInputContainerView(frame: frame)
        c.imgBtn.setTitle("❎", for: .normal)
        c.imgBtn.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        c.sendBtn.setTitle("Search", for: .normal)
        c.sendBtn.backgroundColor = buttonColorPurple
        c.sendBtn.addTarget(self, action: #selector(searchFriendUsers), for: .touchUpInside)
        c.inputTxFd.placeholder = "Search by name or email"
        c.inputTxFd.delegate = self // allow use Enter key to send msg, and add UITextFieldDelegate for class;
        return c
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    let cellId = "searchCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 2
        }
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 90, right: 0) // margin ??????
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor(r: 240, g: 230, b: 252)
        collectionView?.register(SearchViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        
        setupNavigationBar()
        
        setupKeyboardObserver()
    }
    
    private func setupNavigationBar(){
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationItem.title = "Find new friends"
    }

    private func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(moveCollectionViewWhenKeyboardDidShow),
                                               name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    func moveCollectionViewWhenKeyboardDidShow() {
        print("TODO: move collectionView to bottom when keyboard shows: SearchViewController.swift:50")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    // handle rotate between landscape and vertical:
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // setup session of cells: ========================================
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return candidateFriends.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchViewCell
        cell.searchVC = self
        cell.friend = candidateFriends[indexPath.item]
        cell.backgroundColor = .white
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 52)
    }
    
    func clearTextField(){
        inputContainerView.inputTxFd.text = ""
    }
    
    func searchFriendUsers(){
        guard let uid = currUser?.id else { return }
        FIRDatabase.database().reference().child("users").observe(.value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String:AnyObject] else { return }
            //print(userDictionary) // [id:{email,name,img..}; id:{email,name,img..}]
            self.candidateFriends.removeAll()
            for obj in userDictionary {
                //print(obj.value) // {name = xx, email = xx..}
                if let content = obj.value as? [String : AnyObject] {
                    let getUser = User(dictionary: content)
                    getUser.id = obj.key
                    self.setCandidateListBy(user: getUser)

                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            }
            if self.candidateFriends.count == 0 {
                self.showAlertWith(title: "❓Oops, nobody❓", message: "Can not find any user by the keyword, try to use a shorter word or change another one please.")
            }
        })
    }
    func setCandidateListBy(user: User){
        guard let getName = user.name, let getEmail = (user.email)?.components(separatedBy: "@"), user.id != currUser?.id,
              let keyword = inputContainerView.inputTxFd.text?.lowercased(), keyword != "" else {return}
        if isSubstring(testStr: keyword, longstr: getEmail[0]) || isSubstring(testStr: keyword, longstr: getName) {
            candidateFriends.append(user)
        }
    }
    private func isSubstring(testStr:String, longstr:String) -> Bool {
        var i = 0, j = 0
        let test = Array(testStr.lowercased().characters)
        let long = Array(longstr.lowercased().characters)
        while i < test.count, j < long.count {
            if test[i] == long[j] { i += 1 }
            j += 1
        }
        return i == test.count
    }
    
    func sendFriendRequestTo(userId: String?){
        guard let myId = currUser?.id, let friendId = userId else { return }
        let ref = FIRDatabase.database().reference().child("friendRequests").child(friendId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            var newRequests = [String:Bool]()
            if let getList = snapshot.value as? [String:Bool] {
                newRequests = getList //as! [String:Bool]
            }
            newRequests[myId] = true
            ref.setValue(newRequests, withCompletionBlock: { (err, firRef) in
                if err != nil {
                    print("get err: SearchViewController.swift: sendFirendRequestTo(): ", err)
                    self.showAlertWith(title: "Oops! 😰", message: "⛔️ We got an error when sending your request, please try again later.")
                }else{
                    self.showAlertWith(title: "Success 😸", message: "✅ Your request already been send, please wait for response.")
                }
            })
        })
        
    }
    
    
    func showAlertWith(title:String, message:String){
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alertCtrl.dismiss(animated: true, completion: nil)
        }))
        self.present(alertCtrl, animated: true, completion: nil)
    }

}
