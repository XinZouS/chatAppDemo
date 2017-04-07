//
//  ChatMessageCell.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/6/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    var chatLogController : ChatLogController? // for access self.GestureRecognizer
    
    var message: Message?
    
    var indicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        a.hidesWhenStopped = true
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
    lazy var playButton : UIButton = {
        let b = UIButton(type: .system)
        let img = UIImage(named: "playButton_w")
        b.setImage(img, for: .normal)
        b.tintColor = UIColor.white
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        return b
    }()
    
    let textView : UITextView = {
        let tv = UITextView()
        //tv.text = "test txt a b c d e f g h i j"
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let profileImgView: UIImageView = {
        let img = UIImageView()
        //img.image = UIImage(named: "chihiroAndHaku03_500x500")
        img.layer.cornerRadius = 16
        img.layer.masksToBounds = true
        img.contentMode = .scaleAspectFill
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    static let blueColor = UIColor(r: 0, g: 150, b: 230)
    static let grayColor = UIColor(r: 220, g: 220, b: 220)
    
    let bubbleView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear // blueColor
        //v.layer.cornerRadius = 16
        //v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let bubbleImageView : UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        // use image for background in bubbleView, UIEdgeInsetsMake(top, left, bottom, right;), withRenderingMode to allow color change;
        // v.image = #imageLiteral(resourceName: "chatbubbleL").resizableImage(withCapInsets: UIEdgeInsetsMake(35, 60, 35, 60)).withRenderingMode(.alwaysTemplate)
        // setup image in ChatLogController;
        v.tintColor = UIColor(white: 0.9, alpha: 1)
        return v
    }()
    
    lazy var messageImgView: UIImageView = {
        let v = UIImageView()
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.contentMode = .scaleAspectFill
        v.backgroundColor = UIColor.clear
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = true
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomInPicture)) )
        return v
    }()
    func zoomInPicture(tapGesture: UITapGestureRecognizer){
        if message?.videoURL != nil {
            return // not for video, so return;
        }
        //print("======================")
        //PRO tip: do not perform too much logic in a view class!
        // so we do it in ChatLogController.swift, and send reference form here:
        if let img = tapGesture.view as? UIImageView {
            self.chatLogController?.performZoomInForStartingImageView(imgView: img, isVideo: false)
        }
    }
    
    // init anchors in ChatLogController.swift: 
    var profileImgLeftAnchor: NSLayoutConstraint?
    var profileImgRightAnchor:NSLayoutConstraint?
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor:  NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // chatPartner image:
        addSubview(profileImgView)
        profileImgView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true
        profileImgLeftAnchor = profileImgView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 7)
        profileImgRightAnchor = profileImgView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -7)
        profileImgView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImgView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        // backgroundColor = UIColor.green
        addSubview(bubbleView) // add this first!!!
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -43)
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 43)
        // bubbleLeftAnchor?.isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 9).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 230)
        bubbleWidthAnchor?.isActive = true
        
        bubbleView.addSubview(bubbleImageView)
        bubbleImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        bubbleImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        bubbleImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        bubbleImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        
        bubbleView.addSubview(messageImgView)
        messageImgView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        messageImgView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImgView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImgView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        
        bubbleView.addSubview(indicator)
        indicator.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        indicator.widthAnchor.constraint(equalToConstant:  50).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bubbleView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant:  50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bubbleView.addSubview(textView)
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 20).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -10).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        textView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    func playButtonTapped(){
        if let videoUrlStr = message?.videoURL, let url = URL(string: videoUrlStr) {
            
            //PRO tip: do not perform too much logic in a view class! ==============
            // so we do it in ChatLogController.swift, and send reference form here:
            self.chatLogController?.performZoomInForStartingImageView(imgView: messageImgView, isVideo: true)
            self.chatLogController?.playVideoFrom(url: url)
            return
                
//            // play video INSIDE bubble cell: (replaced by above)
//            player = AVPlayer(url: url)
//            playerLayer = AVPlayerLayer(player: player)
//            playerLayer!.frame = bubbleView.bounds
//            bubbleView.layer.addSublayer(playerLayer!)
//            
//            
//            player!.play()
//            indicator.startAnimating()
//            playButton.isHidden = true
//            
//            chatLogController?.playerInCell = player
        }
    }
    override func prepareForReuse() { // avoiding avplayer showing in other cells;
        super.prepareForReuse()
        
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        indicator.stopAnimating() // and it will hide;
    }
    
}
