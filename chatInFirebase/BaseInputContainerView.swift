//
//  BaseInputContainerView.swift
//  chatInFirebase
//
//  Created by Xin Zou on 4/25/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

// a model of input container view
class BaseInputContainerView: UIView, UITextFieldDelegate {
    
    
    lazy var sendBtn : UIButton = {
        let b = UIButton()
        b.setTitle("Send", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.cornerRadius = 6
        b.backgroundColor = buttonColorGreen // UIColor(r: 90, g: 220, b: 90)
        b.tintColor = UIColor.white
        b.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return b
    }()
    
    lazy var imgBtn : UIButton = {
        let i = UIButton()
        i.setTitle("?", for: .normal)
        i.translatesAutoresizingMaskIntoConstraints = false
        i.titleLabel?.font = UIFont(name: "System", size: 26)
        i.addTarget(self, action: #selector(imgButtonTapped), for: .touchUpInside)
        return i
    }()
    
    lazy var inputTxFd : UITextField = {
        let txFd = UITextField()
        txFd.placeholder = "Your message..."
        txFd.translatesAutoresizingMaskIntoConstraints = false
        txFd.delegate = self // allow use Enter key to send msg, and add UITextFieldDelegate for class;
        return txFd
    }()
    // allow use Enter key to send msg:
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    func keyboardDismiss(){
        self.inputTxFd.resignFirstResponder()
        self.endEditing(true)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(sendBtn)
        sendBtn.rightAnchor.constraint(equalTo: rightAnchor, constant: -6).isActive = true
        sendBtn.widthAnchor.constraint(equalToConstant: 70).isActive = true
        sendBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        sendBtn.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
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
    
    open func sendButtonTapped(){
        print("---- you need to override func sendButtonTapped() for inputContainerView()")
    }
    
    open func imgButtonTapped(){
        print("---- you need to override func imgButtonTapped() for inputContainerView()")
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

