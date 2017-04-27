//
//  ChatInputContainerView.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/17/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

//class ChatInputContainerView: UIView, UITextFieldDelegate {
class ChatInputContainerView: BaseInputContainerView {

    var chatLogController : ChatLogController? // setup at ChatLogController when init() this view; 

    // allow use Enter key to send msg:
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController?.sendingInputMsg()
        return true
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        translatesAutoresizingMaskIntoConstraints = false
        
        self.imgBtn.setTitle("🤣", for: .normal)
        
    }
    
    override func sendButtonTapped() {
        chatLogController?.sendingInputMsg()
    }
    
    override func imgButtonTapped() {
        //chatLogController?.selectingImage()
        chatLogController?.showMenuLuncher()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
