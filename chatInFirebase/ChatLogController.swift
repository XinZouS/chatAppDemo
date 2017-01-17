//
//  ChatLogController.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/3/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices // for picking videos
import AVFoundation


class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let containerView = UIView()
    
    var playerInCell: AVPlayer?

    var messages = [Message]()
    
    var currUser : User?
    
    var partnerUser : User? { // as the 'user' in video
        didSet {
            navigationItem.title = partnerUser?.name
            
            observeMessages()
        }
    }
    func observeMessages(){
        guard let myid = FIRAuth.auth()?.currentUser?.uid, let toId = partnerUser?.id else {return}
        let ref = FIRDatabase.database().reference().child("user-messages").child(myid).child(toId)
        ref.observe(.childAdded, with: { (snapshot) in
            
            //print(snapshot) // == MsgId, already did it above...
//            let partnerId = snapshot.key
//            let refParner = FIRDatabase.database().reference().child("user-messages").child(myid).child(partnerId)
//            refParner.observe(.childAdded, with: { (snapshot) in
            
                //print(snapshot)
                let msgId = snapshot.key
                let msgRef = FIRDatabase.database().reference().child("messages").child(msgId)
                msgRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    // print(snapshot)
                    guard let getDictionary = snapshot.value as? [String: AnyObject] else {return}
                    // potential crashing if the keys don't match:
                    // let message = Message() // we change as Msg(dic), so not need following line:
                    // message.setValuesForKeys(getDictionary)
                    // print(message)
                    
                    //if message.chatPartnerId() == self.partnerUser?.id {
                        //self.messages.append(message)
                        self.messages.append( Message(dictionary: getDictionary) )
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                            // and scroll to the last item: 
                            self.scrollerViewMoveToBottom()
                        }
                    //}
                    
                }, withCancel: nil)
                
//            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    func scrollerViewMoveToBottom(){
        if messages.count > 0 {
        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
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
        
        cell.chatLogController = self // for access self.GestureRecognizer

        let msg = messages[indexPath.item]
        cell.message = msg // for ChatMessageCell to get VideoURL
        cell.textLabel.text = msg.text

        setupCell(cell: cell, msg: msg)
        
        if let msgtx = msg.text {
            // mdf width for cell here:
            cell.bubbleWidthAnchor?.constant = estimateFrameFor(text: msgtx).width + 30
        }else
        if msg.imgURL != nil {
            cell.bubbleWidthAnchor?.constant = 220
        }
        //print("do scroller to item to top = \(collectionView.scrollsToTop)")
        //collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        
        // check if the msg is a video:
        cell.playButton.isHidden = (msg.videoURL == nil)
        
        return cell
    }
    private func setupCell(cell: ChatMessageCell, msg: Message){
        if let imgUrl = msg.imgURL {
            cell.messageImgView.loadImageUsingCacheWith(urlString: imgUrl)
            cell.textLabel.isHidden = true
            cell.messageImgView.isHidden = false
        }else{
            cell.textLabel.isHidden = false
            cell.messageImgView.isHidden = true
        }
        
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
        
        let msg = messages[indexPath.item]
        // get the height depends on text: 
        if let tx = msg.text {
            height = estimateFrameFor(text: tx).height + 20
        }else // adjust imgView
        if let imgW = msg.imgWidth?.floatValue, let imgH = msg.imgHeight?.floatValue {
            // h1 / w1 = h2 / w2, so we solve for h1, then:
            // h1 = h2 / w2 * w1:
            // imgH / imgW = bubbleH / 220  // 220 == width;
            height = CGFloat(imgH / imgW * 220)
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
        // collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 1, left: 0, bottom: 60, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.keyboardDismissMode = .interactive // allow user to drag down keyboard
        
//        Solution I : use our original items: ---------------
//        setupInputComponents() // do not need it in II;
        
        setupKeyboardObservers()
        
    }
    // changing between vertical and landscape:
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(moveCollectionViewWhenKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    func moveCollectionViewWhenKeyboardDidShow(){
        self.scrollerViewMoveToBottom()
    }
    // remove the keyboardObserver if we leave this page:
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
/*
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
     
     // remove the keyboardObserver if we leave this page:
     override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
     
        NotificationCenter.default.removeObserver(self)
     }
*/
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
        
        let imgBtn = UIButton()
        imgBtn.setTitle("🏞", for: .normal)
        imgBtn.titleLabel?.font = UIFont(name: "System", size: 26)
        imgBtn.addTarget(self, action: #selector(selectingImage), for: .touchUpInside)
        imgBtn.translatesAutoresizingMaskIntoConstraints = false
        cv.addSubview(imgBtn)
        imgBtn.leftAnchor.constraint(equalTo: cv.leftAnchor).isActive = true
        imgBtn.topAnchor.constraint(equalTo: cv.topAnchor).isActive = true
        imgBtn.bottomAnchor.constraint(equalTo: cv.bottomAnchor).isActive = true
        imgBtn.widthAnchor.constraint(equalToConstant: 46).isActive = true
        
        cv.addSubview(self.inputTxFd)
        self.inputTxFd.leftAnchor.constraint(equalTo: imgBtn.rightAnchor, constant: 6).isActive = true
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
    
    /*
     var containerBottomConstraint : NSLayoutConstraint?
     
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
    func selectingImage(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String] //add this for picking videos; need import MobileCoreServices,AVFoundation
        
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //print("get image info: ", info)
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            // selecting a video:
            //print("--- getting video url: \(videoURL)")
            prepareUploadingVideoTo(url: videoURL)
        }else{
            // selecting an image: 
            prepareUploadingImageFrom(info: info)
        }
        self.dismiss(animated: true, completion: nil)
    }
    private func prepareUploadingVideoTo(url: URL){
        let filename = NSUUID().uuidString + ".mov" // "video.mov"
        let uploadRef = FIRStorage.storage().reference().child("message_video").child("sender: \(currUser!.name!)_\(filename)")
        let uploadTask = uploadRef.putFile(url, metadata: nil, completion: {(metadata, err) in
            if err != nil {
                print("get err when uploading video: \(err)")
                return
            }
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                //print("------ get url: \(storageUrl)")
                // get 1st frame of the video:
                //let thumbnailImg = self.thumbnailImageForFileUrl(fileUrl: url) // not storageUrl!!! // use optional!
                if let thumbnailImg = self.thumbnailImageForFileUrl(fileUrl: url) { // not storageUrl!!!
                    self.uploadToFirebaseByImage(img: thumbnailImg, completion: { (getImgUrl) in // inner func to getImgUrl!
                        let properties : [String: Any] = ["videoURL": videoUrl, "imgURL": getImgUrl,
                                                          "imgWidth": thumbnailImg.size.width,
                                                          "imgHeight": thumbnailImg.size.height]
                        self.sendMessageWithProperties(properties: properties)
                    })
                }
            }
        })
        uploadTask.observe(.progress){ (snapshot) in
            //print(snapshot.progress?.completedUnitCount)
            if let completeUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completeUnitCount)
            }
        }
        uploadTask.observe(.success){ (snapshot) in
            self.navigationItem.title = self.currUser?.name
        }
    }
    private func thumbnailImageForFileUrl(fileUrl: URL) -> UIImage? { // get the 1st frame of video, use optional!!
        let asset = AVAsset(url: fileUrl)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnailCGImg = try imgGenerator.copyCGImage(at: CMTimeMake(3, 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailCGImg) // get the real image;
        } catch let err {
            print("get err when converting CGimg of 1st frame: \(err), ---> ChatLogController.swift:410")
        }
        return nil
    }
    private func prepareUploadingImageFrom(info: [String:Any]){
        var getImg : UIImage?
        
        if let originalImg = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            getImg = originalImg
        }else if let editedImg = info["UIImagePickerControllerEditedImage"] as? UIImage {
            getImg = editedImg
        }
        if let readyImg = getImg {
            //uploadToFirebaseByImage(img: readyImg) // replaced by inner func:
            uploadToFirebaseByImage(img: readyImg, completion: { (imgUrl) in
                self.sendMssageWithImgURL(imgURL: imgUrl, img: readyImg)
            })
        }
    }
//    private func uploadToFirebaseByImage(img: UIImage){ // using inner func for callback imgURL:
    private func uploadToFirebaseByImage(img: UIImage, completion: @escaping (_ imgURL: String) -> () ){
        let imgId = NSUUID().uuidString // ??? use of unresolved identifier 'FIRStorage' ???
        let refImg = FIRStorage.storage().reference().child("message_image").child("sender: \(currUser!.name!)_\(imgId)")
        
        if let uploadData = UIImageJPEGRepresentation(img, 0.2) {
            refImg.put(uploadData, metadata: nil, completion: {(metadata, err) in
                
                if err != nil {
                    print("get err when uploading message_image: \(err)")
                    return
                }
                //print(metadata)
//                if let imgURL = metadata?.downloadURL()?.absoluteString {
//                    //print("======= url: \(imgURL)")
//                    self.sendMssageWithImgURL(imgURL: imgURL, img: img)
//                }
                // to reuse code above, replace them by inner func:
                if let imgURL = metadata?.downloadURL()?.absoluteString {
                    completion(imgURL)
                }
                
            })
        }

    }
    private func sendMssageWithImgURL(imgURL:String, img:UIImage){
//        let ref = FIRDatabase.database().reference().child("messages")
//        let childRef = ref.childByAutoId()
//        let toId = partnerUser!.id
//        let fromId = FIRAuth.auth()?.currentUser?.uid
//        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
//        
//        let value = ["toId":toId, "fromId": fromId, "timeStamp": timestamp,
//                     "imgURL":imgURL, "imgWidth": img.size.width, "imgHeight": img.size.height] as [String: Any]
//        
//        childRef.updateChildValues(value, withCompletionBlock: { (err, ref) in
//            if err != nil {
//                print("error when uploading message img: ", err!)
//                return
//            }
//            let msgId = childRef.key
//            
//            let userMsgRef = FIRDatabase.database().reference().child("user-messages").child(fromId!).child(toId!)
//            userMsgRef.updateChildValues([msgId: 1])
//            
//            let recipientUserRef = FIRDatabase.database().reference().child("user-messages").child(toId!).child(fromId!)
//            recipientUserRef.updateChildValues([msgId: 1])
//        
//        })
        // above code replased by following for reusable code:
        let property : [String: Any] = ["imgURL":imgURL, "imgWidth": img.size.width, "imgHeight": img.size.height]
        
        sendMessageWithProperties(properties: property)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    
    func sendingInputMsg() {
        if let userText = inputTxFd.text, userText != "" {
//            let ref = FIRDatabase.database().reference().child("messages")
//            let childRef = ref.childByAutoId() // parent node to save msgs;
//            let toId = partnerUser!.id
//            let fromId = FIRAuth.auth()?.currentUser?.uid
//            let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
//            
//            let value = ["text":userText, "toId": toId, "fromId": fromId, "timeStamp": timestamp] as [String : Any]
//            // childRef.updateChildValues(value) // replace this with following to send msg: 
//            childRef.updateChildValues(value, withCompletionBlock: { (err, ref) in
//                if err != nil {
//                    print("get err when sending msg: \(err!), in ChatLogController.swift: 100")
//                    return
//                }
//                // new a ref to save 'fromId':
//                let msgId = childRef.key // ref.childByAutoId(), the parent node for msgs;
//
//                let userMsgRef = FIRDatabase.database().reference().child("user-messages").child(fromId!).child(toId!)
//                userMsgRef.updateChildValues([msgId: 1]) // save it into 'user-messages';
//
//                let recipientUserRef = FIRDatabase.database().reference().child("user-messages").child(toId!).child(fromId!)
//                recipientUserRef.updateChildValues([msgId: 1])
//            })
            // above code replased by following for reusable code:
            let property : [String:Any] = ["text":userText]
            
            sendMessageWithProperties(properties: property)
            
            inputTxFd.text = ""
            
        }
    }
    
    private func sendMessageWithProperties(properties:[String:Any]){
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = partnerUser!.id
        let fromId = FIRAuth.auth()?.currentUser?.uid
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        var value: [String:Any] = ["toId":toId, "fromId": fromId, "timeStamp": timestamp]
        // then append coming in properties to this value: 
        // key: $0, value: $1
        properties.forEach({ value[$0] = $1 })
        
        childRef.updateChildValues(value, withCompletionBlock: { (err, ref) in
            if err != nil {
                print("error when uploading message img: ", err!)
                return
            }
            let msgId = childRef.key
            
            let userMsgRef = FIRDatabase.database().reference().child("user-messages").child(fromId!).child(toId!)
            userMsgRef.updateChildValues([msgId: 1])
            
            let recipientUserRef = FIRDatabase.database().reference().child("user-messages").child(toId!).child(fromId!)
            recipientUserRef.updateChildValues([msgId: 1])
            
        })
    }
    
    var startFrame : CGRect?
    var blurEffectView : UIVisualEffectView! // for img zoom in background
    // my custom zoom in-out func: pointer from ChatMessageCell.swift;
    func performZoomInForStartingImageView(imgView: UIImageView){
        startFrame = imgView.superview?.convert(imgView.frame, to: nil)
        //print(startFrame)
        let zoomingImgView = UIImageView(frame: startFrame!)
        //zoomingImgView.backgroundColor = UIColor.cyan
        zoomingImgView.image = imgView.image
        zoomingImgView.isUserInteractionEnabled = true
        zoomingImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performZoomOutOf)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style:.light) )
            blurEffectView.isHidden = false
            blurEffectView.frame = self.view.bounds
            blurEffectView.center = self.view.center
            blurEffectView.effect = UIBlurEffect(style: .light)
            blurEffectView.alpha = 0
            //blurEffectView.isUserInteractionEnabled = true
            //blurEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performZoomOutOf)))
            
            keyWindow.addSubview(blurEffectView) // as background;
            keyWindow.addSubview(zoomingImgView) // duplicate an ImageView;
            
            //UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: { // use a more smooth animation:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { 
                // h1 / w1 = h2 / w2, to get new height h1, we do :
                // h1 = h2 / w2 * w1, then:
                let newWidth = keyWindow.frame.width
                let newHeight = imgView.frame.height / imgView.frame.width * newWidth
                zoomingImgView.frame = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
                zoomingImgView.center = keyWindow.center
                
                self.blurEffectView.alpha = 1
                self.inputContainerView.alpha = 0
                
            }, completion: nil)
        }
    }
    func performZoomOutOf(tapGesture:UITapGestureRecognizer){
        //print("getting zoom out.......")
        if let zoomOutView = tapGesture.view {
            zoomOutView.layer.cornerRadius = 16
            zoomOutView.clipsToBounds = true
            
            //UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: { // use a more smooth animation:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                zoomOutView.frame = self.startFrame!
                self.blurEffectView.alpha = 0
                self.inputContainerView.alpha = 1

            }) { (completed: Bool) in
                //self.blurEffectView.isHidden = true
                self.blurEffectView.removeFromSuperview()
                zoomOutView.removeFromSuperview()
            }
        }
    }
    
}
