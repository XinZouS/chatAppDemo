//
//  ChatLogViewAddingMenu.swift
//  chatInFirebase
//
//  Created by Xin Zou on 5/2/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit
import Firebase


class ChatLogAddMenuLuncher : SmallTopRightMenuLuncher {
    
    var chatLogController : ChatLogController?
    
    override init(){
        super.init()
        
        setupAddMenuItems()
        
    }
    
    private func setupAddMenuItems(){
        let itemViewNameCard = AddMenuItem(title: ItemTitle.nameCard, icon: #imageLiteral(resourceName: "guaiqiao80x80"))
        let itemClearChatHistory = AddMenuItem(title: ItemTitle.clear, icon: #imageLiteral(resourceName: "paw-print_64x64@1x")) // paw-print_512x512
        let itemReport = AddMenuItem(title: ItemTitle.report, icon: #imageLiteral(resourceName: "catAngryIcon91x91"))
        let itemBlock = AddMenuItem(title: ItemTitle.blockUser, icon: #imageLiteral(resourceName: "dogStopIcon150x150"))
        items = [itemViewNameCard, itemClearChatHistory, itemReport, itemBlock]
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < self.items.count, let getTitle = items[indexPath.item].title else { return }
        
        switch getTitle {
        case ItemTitle.nameCard:
            chatLogController?.showFriendNamecard()
        case ItemTitle.clear:
            chatLogController?.removeChatHistory()
        case ItemTitle.report:
            sendReport()
            chatLogController?.removeChatHistory()
        case ItemTitle.blackList:
            chatLogController?.blockThisFriend()
        default:
            dismissWithoutSelection()
        }
        dismissWithoutSelection()
    }
    
    private func sendReport(){
        let ref = FIRDatabase.database().reference().child("reportsAbuse").child("user")
        let values : [String:String] = [(chatLogController?.partnerUser?.id)! : (chatLogController?.partnerUser?.name)!]
        ref.updateChildValues(values, withCompletionBlock: {(err, ref) in
            var title = "✅ Report Success"
            var msg = "📬 We are receiving your report and will handle the objectionable content in 24 hours. 😀Thank you for your reporting!"
            if let err = err {
                title = "Oops❗️"
                msg = "⚠️ Report did not send. I apologize for that, please make sure you have the Internet access and try again later. \(err)"
            }
            self.chatLogController?.showAlertWith(title: title, message: msg)
        })
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
