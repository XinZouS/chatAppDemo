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

    var messages = [Message]()
    
    var user : User? {
        didSet {
            navigationItem.title = user?.name
            
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
                if message.chatPartnerId() == self.user?.id {
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
        txFd.placeholder = "Input your message..."
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        // get the height depends on text: 
        if let tx = messages[indexPath.item].text {
            height = estimateFrameFor(text: tx).height + 20
        }
        
        return CGSize(width: self.view.frame.width, height: height)
    }
    
    private func estimateFrameFor(text: String) -> CGRect {
        let sz = CGSize(width: 270, height: 1000)
        let opts = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: sz, options: opts, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context:nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupInputComponents()
    }
    
    func setupInputComponents() {

        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
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
    
    
    func sendingInputMsg() {
        if let userText = inputTxFd.text, userText != "" {
            let ref = FIRDatabase.database().reference().child("messages")
            let childRef = ref.childByAutoId() // parent node to save msgs;
            let toId = user!.id
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
