//
//  ChatLogView.swift
//  chatInFirebase
//
//  Created by Xin Zou on 4/20/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit
import Firebase


extension ChatLogController {
    
    func setupCell(cell: ChatMessageCell, msg: Message){
        if let imgUrl = msg.imgURL {
            cell.messageImgView.loadImageUsingCacheWith(urlString: imgUrl)
            cell.textView.isHidden = true
            cell.messageImgView.isHidden = false
        }else{
            cell.textView.isHidden = false
            cell.messageImgView.isHidden = true
        }
        
        if msg.fromId == FIRAuth.auth()?.currentUser?.uid {
            //outgoing blue:
            if let myImgURL = self.currUser?.profileImgURL {
                cell.profileImgView.loadImageUsingCacheWith(urlString: myImgURL)
            }
            //cell.bubbleView.backgroundColor = ChatMessageCell.blueColor // replaced by bubble image:
            // use image for background in bubbleView, UIEdgeInsetsMake(top, right, bottom, left;), withRenderingMode to allow color change;
            cell.bubbleImageView.image = #imageLiteral(resourceName: "chatbubbleR").resizableImage(withCapInsets: UIEdgeInsetsMake(33, 33, 33, 36)).withRenderingMode(.alwaysTemplate)
            cell.bubbleImageView.tintColor = ChatMessageCell.purpleColor
            cell.textView.textColor = UIColor.white
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
            //cell.profileImgView.isHidden = true
            cell.profileImgRightAnchor?.isActive = true
            cell.profileImgLeftAnchor?.isActive = false
        }else{
            //incoming gray:
            if let profileImgURL = self.partnerUser?.profileImgURL {
                cell.profileImgView.loadImageUsingCacheWith(urlString: profileImgURL)
            }
            //cell.bubbleView.backgroundColor = ChatMessageCell.grayColor // replaced by bubble image:
            // use image for background in bubbleView, UIEdgeInsetsMake(top, right, bottom, left;), withRenderingMode to allow color change;
            cell.bubbleImageView.image = #imageLiteral(resourceName: "chatbubbleL").resizableImage(withCapInsets: UIEdgeInsetsMake(33, 33, 33, 36)).withRenderingMode(.alwaysTemplate)
            cell.bubbleImageView.tintColor = ChatMessageCell.grayColor
            cell.textView.textColor = UIColor.black
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
            //cell.profileImgView.isHidden = false
            cell.profileImgLeftAnchor?.isActive = true
            cell.profileImgRightAnchor?.isActive = false
        }
    }

    // for animate effect of emoji characters: 
    func animateCurveFlowFor(inputStr: String, num: Int){
        if num < 1 { return }
        
        let bonusNum = 16
        
        if inputStr.containsEmoji {
            let str = inputStr.emojiString
            animateCurveFlowBy(emojiStr: str, num: 10)
        }else{ // see if it has some keywords:
            //var newStr : String = ""
            let words = (inputStr.lowercased()).components(separatedBy: [" ", "!", "~", "@", ",", "."])
            let wordSet = Set<String>(words)
            let emojiOfWord : [String:String] = [
                "birthday":"🎂", "happy":"😄", "hi":"😄", "smile":"😄", "ha":"🤣", "haha":"😁", "hahaha":"🤣😂",
                "what?":"😯", "?":"😯❓", "??":"🤔❓", "???":"😳❓",
                "mouse":"🐹", "hamster":"🐹", "mice":"🐹", "bull":"🐂" , "ox":"🐂", "tiger":"🐯", "tigers":"🐯", "rabbit":"🐰", "hare":"🐰", "dragon":"🐲",
                "snake":"🐍", "serpent":"🐍", "horse":"🐴", "pony":"🐴", "horses":"🐴", "goat":"🐐", "goats":"🐐🐏", "sheep":"🐑", "ram":"🐐🐏",
                "monkey":"🐵", "monkeys":"🐒🐵", "rooster":"🐓", "dog":"🐶", "puppy":"🐶", "pig":"🐷", "chick":"🐥", "chicken":"🐥", "love":"💘",
                "milk":"🥛", "breakfast":"🥛" //, "":"", "":"", "":""
            ]
            let emojiWordSet : Set<String> = Set(emojiOfWord.keys)
            let targetWordSet: Set<String> = wordSet.intersection(emojiWordSet)
            if targetWordSet.count == 0 { return }
            let targetEmojis : [String] = targetWordSet.map{ emojiOfWord[$0]! }
            var targetString : String = targetEmojis.reduce("", + )
            if targetString.characters.count > 5 {
                targetString = targetString.substring(to: targetString.index(targetString.startIndex, offsetBy: 5) )
            }

            animateCurveFlowBy(emojiStr: targetString, num: bonusNum)
        }
    }
    
    func animateCurveFlowBy(emojiStr: String, num: Int){
        var count = 1
        for emoji in emojiStr.unicodeScalars {
            if !emoji.isEmoji || count > 5 { continue }
            count += 1
            (0...num).forEach { (_) in
                generateAnimationOf(emoji: String(emoji))
            }
        }
    }
    
    fileprivate func generateAnimationOf(emoji: String){
        let curvedView = CurvedView(frame: self.view.frame)
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = curvedView.customPath().cgPath // convert UIBezierPath to CGPath/CGGraph!
        animation.duration = 2 + drand48() * 5
        animation.fillMode = kCAFillModeForwards // not go back to original point after animation;
        animation.isRemovedOnCompletion = false  // will remove node after completion
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let dimension = 60
        let node = UILabel(frame: CGRect(x: -30, y: 0, width: dimension, height: dimension))
        node.text = emoji // "🤣"
        node.font = UIFont.systemFont(ofSize: 15 + CGFloat(drand48() * 30))
        node.layer.add(animation, forKey: nil)
        view.addSubview(node)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



class CurvedView : UIView {
    
    override func draw(_ rect: CGRect) {
        
        let path = customPath()
        //path.lineWidth = 3
        path.stroke()
    }
    
    func customPath() -> UIBezierPath {
        let path = UIBezierPath()
        
        // starting point
        let xlen = Double(self.frame.width + 60)
        let ylen = Double(self.frame.height - 100) * 0.7
        let yshift = 100 + drand48() * ylen
        path.move(to: CGPoint(x: -20, y: yshift)) // start point
        let endPoint = CGPoint(x: xlen, y: yshift)
        //path.addLine(to: endPoint) // also, we need curve, not only line:
        let dx = drand48() * 100
        //let dy = drand48() * ylen
        let cp1 = CGPoint(x: 50 + Double(xlen / 3) - dx, y: drand48() * ylen)
        let cp2 = CGPoint(x: Double(xlen / 1.5) + dx, y: drand48() * ylen)
        path.addCurve(to: endPoint, controlPoint1: cp1, controlPoint2: cp2)
        
        path.stroke()
        
        return path
    }
}


