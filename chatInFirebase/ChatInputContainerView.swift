//
//  ChatInputContainerView.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/17/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate {
    
    var chatLogController : ChatLogController? // setup at ChatLogController when init() this view; 

    
    
    lazy var inputTxFd : UITextField = {
        let txFd = UITextField()
        txFd.placeholder = "Your message..."
        txFd.translatesAutoresizingMaskIntoConstraints = false
        txFd.delegate = self // allow use Enter key to send msg, and add UITextFieldDelegate for class;
        return txFd
    }()
    // allow use Enter key to send msg:
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController!.sendingInputMsg()
        return true
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(cv) // BUG: do NOT add these in the view.self:
//        cv.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        cv.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
//        cv.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendBtn = UIButton()
        sendBtn.setTitle("Send", for: .normal)
//        sendBtn.addTarget(self, action: #selector(chatLogController!.sendingInputMsg), for: .touchUpInside)
        sendBtn.addTarget(chatLogController, action: #selector(chatLogController!.sendingInputMsg), for: .touchUpInside)
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        sendBtn.layer.cornerRadius = 6
        sendBtn.backgroundColor = UIColor(r: 90, g: 220, b: 90)
        sendBtn.tintColor = UIColor.white
        addSubview(sendBtn)
        sendBtn.rightAnchor.constraint(equalTo: rightAnchor, constant: -6).isActive = true
        sendBtn.widthAnchor.constraint(equalToConstant: 70).isActive = true
        sendBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        sendBtn.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        let imgBtn = UIButton()
        imgBtn.setTitle("🏞", for: .normal)
        imgBtn.titleLabel?.font = UIFont(name: "System", size: 26)
        imgBtn.addTarget(chatLogController, action: #selector(chatLogController!.selectingImage), for: .touchUpInside)
        imgBtn.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imgBtn)
        imgBtn.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imgBtn.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imgBtn.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imgBtn.widthAnchor.constraint(equalToConstant: 46).isActive = true
        
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        addSubview(line)
        line.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 2).isActive = true
        line.topAnchor.constraint(equalTo: topAnchor, constant: -2).isActive = true
        
        addSubview(self.inputTxFd)
        inputTxFd.leftAnchor.constraint(equalTo: imgBtn.rightAnchor, constant: 6).isActive = true
        inputTxFd.rightAnchor.constraint(equalTo: sendBtn.leftAnchor, constant: -6).isActive = true
        inputTxFd.heightAnchor.constraint(equalToConstant: 40)
        inputTxFd.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
