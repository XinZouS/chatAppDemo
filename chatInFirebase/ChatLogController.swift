//
//  ChatLogController.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/3/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {

    let containerView = UIView()

    var messages = [Message]()
    
    var currUser : User?
    
    var partnerUser : User? {
        didSet {
            navigationItem.title = partnerUser?.name
            
            observeMessages()
        }
    }
    func observeMessages(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            //print(snapshot)
            let msgId = snapshot.key
            let msgRef = FIRDatabase.database().reference().child("messages").child(msgId)
            msgRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
                // print(snapshot)
                guard let dictionary = snapshot.value as? [String: AnyObject] else {return}
                let message = Message()
                // potential crashing if the keys don't match:
                message.setValuesForKeys(dictionary)
                // print(message)
                if message.chatPartnerId() == self.partnerUser?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
                
            
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    lazy var inputTxFd : UITextField = {
        let txFd = UITextField()
        txFd.placeholder = "Your message..."
        txFd.translatesAutoresizingMaskIntoConstraints = false
        txFd.delegate = self // allow use Enter key to send msg, and add UITextFieldDelegate for class;
        return txFd
    }()
    // allow use Enter key to send msg:
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendingInputMsg()
        return true
    }
    
    let cellId = "cellId"
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        // regist in viewDidLoad(){collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)}

        let msg = messages[indexPath.item]
        cell.textLabel.text = msg.text

        setupCell(cell: cell, msg: msg)
        
        // mdf width for cell here:
        cell.bubbleWidthAnchor?.constant = estimateFrameFor(text: msg.text!).width + 30
        
        //print("do scroller to item to top = \(collectionView.scrollsToTop)")
        //collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, msg: Message){
        if msg.fromId == FIRAuth.auth()?.currentUser?.uid { // myself ------
            //outgoing blue:
            if let myImgURL = self.currUser?.profileImgURL {
                cell.profileImgView.loadImageUsingCacheWith(urlString: myImgURL)
            }
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textLabel.textColor = UIColor.white
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
            //cell.profileImgView.isHidden = true
            cell.profileImgRightAnchor?.isActive = true
            cell.profileImgLeftAnchor?.isActive = false
        }else{
            //incoming gray: ----------------------------- // my chatPartner
            if let profileImgURL = self.partnerUser?.profileImgURL {
                cell.profileImgView.loadImageUsingCacheWith(urlString: profileImgURL)
            }
            cell.bubbleView.backgroundColor = ChatMessageCell.grayColor
            cell.textLabel.textColor = UIColor.black
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
            //cell.profileImgView.isHidden = false
            cell.profileImgLeftAnchor?.isActive = true
            cell.profileImgRightAnchor?.isActive = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        // get the height depends on text: 
        if let tx = messages[indexPath.item].text {
            height = estimateFrameFor(text: tx).height + 20
        }
        let width = UIScreen.main.bounds.width // for landscape to change collection view
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameFor(text: String) -> CGRect {
        let sz = CGSize(width: 230, height: 1000)
        let opts = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: sz, options: opts, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context:nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 76, right: 0) // margin on top;
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 1, left: 0, bottom: 60, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.keyboardDismissMode = .interactive // allow user to drag down keyboard
        
//        Solution I : use our original items:
//        setupInputComponents()
//        
//        setUpKeyboardObservers()
        
    }
    // changing between vertical and landscape:
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // Solution I : ------------------------------------------
    func setUpKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    // will call this when keyboard shows up:
    func keyboardWillShow(notification: Notification) {
        //print(notification.userInfo) // see what's inside:
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        //print(keyboardFrame)
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        containerBottomConstraint?.constant = -keyboardFrame.height
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded() // use this for constraint animation;
        }
    }
    func keyboardWillHide(notification: Notification) {
        print("keyboard will hide: \(notification)")
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        containerBottomConstraint?.constant = 0
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded() // use this for constraint animation;
        }
    }

    // Solution II: -----------------------------------------------
    // input container move with keyboard before keyboard will hide: 
    lazy var inputContainerView : UIView = {
        let cv = UIView()
        cv.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)        
        cv.backgroundColor = UIColor.white
        cv.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(cv) // BUG: do NOT add these in the view.self:
//        cv.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        cv.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
//        cv.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendBtn = UIButton()
        sendBtn.setTitle("Send", for: .normal)
        sendBtn.addTarget(self, action: #selector(sendingInputMsg), for: .touchUpInside)
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        sendBtn.layer.cornerRadius = 6
        sendBtn.backgroundColor = UIColor(r: 90, g: 220, b: 90)
        sendBtn.tintColor = UIColor.white
        cv.addSubview(sendBtn)
        sendBtn.rightAnchor.constraint(equalTo: cv.rightAnchor, constant: -6).isActive = true
        sendBtn.widthAnchor.constraint(equalToConstant: 70).isActive = true
        sendBtn.bottomAnchor.constraint(equalTo: cv.bottomAnchor, constant: -4).isActive = true
        sendBtn.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        cv.addSubview(self.inputTxFd)
        self.inputTxFd.leftAnchor.constraint(equalTo: cv.leftAnchor, constant: 6).isActive = true
        self.inputTxFd.rightAnchor.constraint(equalTo: sendBtn.leftAnchor, constant: -6).isActive = true
        self.inputTxFd.heightAnchor.constraint(equalToConstant: 40)
        self.inputTxFd.centerYAnchor.constraint(equalTo: cv.centerYAnchor).isActive = true
        
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        cv.addSubview(line)
        line.leftAnchor.constraint(equalTo: cv.leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: cv.rightAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 2).isActive = true
        line.topAnchor.constraint(equalTo: cv.topAnchor, constant: -2).isActive = true

        return cv
    }()
    override var inputAccessoryView: UIView? {
        get{ // put my inputViewItems:UIView inside here!!!!!

            return inputContainerView
        }
    }
    override var canBecomeFirstResponder: Bool { // for input textField get curser;
        get{
            return true
        }
    }
    
    // remove the keyboardObserver if we leave this page: 
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    var containerBottomConstraint : NSLayoutConstraint?
    
    /*
    func setupInputComponents() {

        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        containerBottomConstraint = containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        containerBottomConstraint?.isActive = true // do this when keyboard pop
        containerView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        let sendBtn = UIButton()
        sendBtn.setTitle("Send", for: .normal)
        sendBtn.addTarget(self, action: #selector(sendingInputMsg), for: .touchUpInside)
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        sendBtn.layer.cornerRadius = 6
        sendBtn.backgroundColor = UIColor(r: 90, g: 220, b: 90)
        sendBtn.tintColor = UIColor.white
        containerView.addSubview(sendBtn)
        sendBtn.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -6).isActive = true
        sendBtn.widthAnchor.constraint(equalToConstant: 70).isActive = true
        sendBtn.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6).isActive = true
        sendBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        containerView.addSubview(inputTxFd)
        inputTxFd.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 6).isActive = true
        inputTxFd.rightAnchor.constraint(equalTo: sendBtn.leftAnchor, constant: -6).isActive = true
        inputTxFd.heightAnchor.constraint(equalToConstant: 60)
        inputTxFd.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        containerView.addSubview(line)
        line.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 2).isActive = true
        line.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    }
*/
    
    func sendingInputMsg() {
        if let userText = inputTxFd.text, userText != "" {
            let ref = FIRDatabase.database().reference().child("messages")
            let childRef = ref.childByAutoId() // parent node to save msgs;
            let toId = partnerUser!.id
            let fromId = FIRAuth.auth()?.currentUser?.uid
            let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
            
            let value = ["text":userText, "toId": toId, "fromId": fromId, "timeStamp": timestamp] as [String : Any]
            // childRef.updateChildValues(value) // replace this with following to send msg: 
            childRef.updateChildValues(value, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print("get err when sending msg: \(err!), in ChatLogController.swift: 100")
                    return
                }
                // new a ref to save 'fromId':
                let msgId = childRef.key // ref.childByAutoId(), the parent node for msgs;

                let userMsgRef = FIRDatabase.database().reference().child("user-messages").child(fromId!)
                userMsgRef.updateChildValues([msgId: 1]) // save it into 'user-messages';

                let recipientUserRef = FIRDatabase.database().reference().child("user-messages").child(toId!)
                recipientUserRef.updateChildValues([msgId: 1])
            })
            
            inputTxFd.text = ""
            
            
        }
    }
    
}
