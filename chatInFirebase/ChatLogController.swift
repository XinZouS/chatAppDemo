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

    //let containerView = UIView() // replaced by inputView on top of keyboard;
    
    var player: AVPlayer?

    let cellId = "cellId"
    
    var messages = [Message]()
    
    var currUser : User?
    
    var partnerUser : User? { // as the 'user' in video
        didSet {
            navigationItem.title = partnerUser?.name
            
            observeMessages()
        }
    }
    func observeMessages(){
        guard let myid = FIRAuth.auth()?.currentUser?.uid, let toId = partnerUser?.id, let ptrName = partnerUser?.name else {return}

        loadMessagesFromDiskFor(partnerName: ptrName)
        
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
                    // let message = Message() // we change as Msg(dict), so not need following line:
                    // message.setValuesForKeys(getDictionary)
                    // print(message)
                    
                    //if message.chatPartnerId() == self.partnerUser?.id {
                        //self.messages.append(message)
                    let newMessage = Message(dictionary: getDictionary)
                    if self.hasMsgInDiskTheSameAs(newMessage) == false {
                        print("messages not contains newMsg, start fetch from firebase;=====")
                        self.messages.append( newMessage )
                    
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                            self.scrollerViewMoveToBottom()
                            
                            self.saveMessagesToDiskFor(partnerName: ptrName)
                        }
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
    private func saveMessagesToDiskFor(partnerName:String){
        let userDefaults = UserDefaults.standard
        let encodeData : Data = NSKeyedArchiver.archivedData(withRootObject: messages)
        userDefaults.set(encodeData, forKey: "\(partnerName)Messages")
        userDefaults.synchronize()
    }
    private func loadMessagesFromDiskFor(partnerName: String?){
        guard let name = partnerName else { return }
        if let decodeed = UserDefaults.standard.object(forKey: "\(name)Messages") as? Data {
            let decodeItems = NSKeyedUnarchiver.unarchiveObject(with: decodeed) as! [Message]
            //print("decodeItems: ", decodeItems)
            messages.append(contentsOf: decodeItems)
        }
    }
    private func hasMsgInDiskTheSameAs(_ msg: Message) -> Bool {
        guard let newTimeStamp = msg.timeStamp else { return false }
        for localMsg in messages {
            if localMsg.timeStamp == newTimeStamp { return true }
        }
        return false
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        // regist in viewDidLoad(){collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)}
        
        cell.chatLogController = self // for access self.GestureRecognizer

        let msg = messages[indexPath.item]
        cell.message = msg // for ChatMessageCell to get VideoURL
        cell.textView.text = msg.text

        setupCell(cell: cell, msg: msg)
        
        if let msgtx = msg.text {
            // mdf width for cell here:
            cell.bubbleWidthAnchor?.constant = estimateFrameFor(text: msgtx).width + 50
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
            cell.bubbleImageView.tintColor = ChatMessageCell.blueColor
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
    
    // cell size:
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let msg = messages[indexPath.item]
        // get the height depends on text: 
        if let tx = msg.text {
            height = estimateFrameFor(text: tx).height + 25
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
        let sz = CGSize(width: 200, height: 1000)
        let opts = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: sz, options: opts, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15)], context:nil)
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
    // changing between vertical and landscape:
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
/*  //Moving input area with keyboard and make it stick on top of keyboard;
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
    lazy var inputContainerView : ChatInputContainerView = {
        let cframe = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        let cv = ChatInputContainerView(frame: cframe)
        cv.chatLogController = self
        
        return cv
    }()
    override var inputAccessoryView: UIView? { // move it with keyboard;
        get{ // put my inputViewItems:UIView inside here!!!!!

            return inputContainerView
        }
    }
    override var canBecomeFirstResponder: Bool { // for input textField get curser;
        get{
            return true
        }
    }
    
    func selectingImage(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String] //add this for picking videos; need import MobileCoreServices,AVFoundation
        
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //print("get image info: ", info)
        if let videoLocalURL = info[UIImagePickerControllerMediaURL] as? URL {
            // selecting a video:
            //print("--- getting video url: \(videoURL)")
            prepareUploadingVideoTo(url: videoLocalURL)
        }else{
            // selecting an image: 
            prepareUploadingImageFrom(info: info)
        }
        self.dismiss(animated: true, completion: nil)
    }
    private func prepareUploadingVideoTo(url: URL){
        let filename = "\(currUser!.name!)_\(NSUUID().uuidString).mov" // "video.mov"
        let uploadRef = FIRStorage.storage().reference().child("message_video").child(filename)
        
        let uploadTask = uploadRef.putFile(url, metadata: nil, completion: {(metadata, err) in
            if err != nil {
                print("get err when uploading video: \(err)")
                return
            }
            if let videoDownloadUrl = metadata?.downloadURL()?.absoluteString {
                //print("------ get url: \(storageUrl)")
                // get 1st frame of the video:
                //let thumbnailImg = self.thumbnailImageForFileUrl(fileUrl: url) // not storageUrl!!! // use optional!
                if let thumbnailImg = self.thumbnailImageForFileUrl(fileUrl: url) { // not storageUrl!!!
                    self.uploadToFirebaseByImage(img: thumbnailImg, fileName: filename, completion: { (getImgUrl) in // inner func to getImgUrl!
                        let properties : [String: Any] = ["videoURL": videoDownloadUrl, "imgURL": getImgUrl,
                                                          "imgWidth": thumbnailImg.size.width,
                                                          "imgHeight": thumbnailImg.size.height,
                                                          "fileName": filename]
                        self.sendMessageWithProperties(properties: properties)
                    })
                }
            }
        })
        uploadTask.observe(.progress){ (snapshot) in
            //print(snapshot.progress?.completedUnitCount)
            if let completeUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = "Uploading..." + String(completeUnitCount)
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
        var selectedImgFromPicker : UIImage?
        //print(info)
        if let editedImg = info["UIImagePickerControllerEditedImage"] {
            selectedImgFromPicker = editedImg as? UIImage
        }else if let originalImg = info["UIImagePickerControllerOriginalImage"] {
            selectedImgFromPicker = originalImg as? UIImage
        }
        if let readyImg = selectedImgFromPicker {
            //uploadToFirebaseByImage(img: readyImg) // replaced by inner func:
            let fName = "\(currUser!.name!)_\(NSUUID().uuidString).jpg" // "video.mov"
            uploadToFirebaseByImage(img: readyImg, fileName: fName, completion: { (imgUrl) in
                self.sendMssageWithImgURL(imgURL: imgUrl, img: readyImg, fileName: fName)
            })
        }
    }
//    private func uploadToFirebaseByImage(img: UIImage){ // using inner func for callback imgURL:
    private func uploadToFirebaseByImage(img: UIImage, fileName:String, completion: @escaping (_ imgURL: String) -> () ){
        //let imgId = NSUUID().uuidString // use fileName to replace uuid:
        let refImg = FIRStorage.storage().reference().child("message_image").child(fileName)
        
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
                if let getImgURL = metadata?.downloadURL()?.absoluteString {
                    completion(getImgURL) // will send URL with msg by func caller;
                }
                
            })
        }

    }
    private func sendMssageWithImgURL(imgURL:String, img:UIImage, fileName:String){
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
        let property : [String: Any] = ["imgURL":imgURL, "imgWidth": img.size.width, "imgHeight": img.size.height, "fileName":fileName]
        
        sendMessageWithProperties(properties: property)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    
    func sendingInputMsg() {
        if let userText = inputContainerView.inputTxFd.text, userText != "" {
            // complicate way to do sending:-----------------------------------
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
            // above code replased by following for reusable code:------------
            let property : [String:Any] = ["text":userText]
            
            sendMessageWithProperties(properties: property)
            
            inputContainerView.inputTxFd.text = ""
            
        }
    }
    
    private func sendMessageWithProperties(properties:[String:Any]){
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = partnerUser!.id
        let fromId = FIRAuth.auth()?.currentUser?.uid
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        let isDeletedByPartner = false
        
        var value: [String:Any] = ["toId":toId, "fromId": fromId, "timeStamp": timestamp, "isDeletedByPartner": isDeletedByPartner]
        // then append coming in properties to this value: 
        // key: $0, value: $1
        properties.forEach({ value[$0] = $1 }) // value += properties;
        
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
    
    private var startFrame : CGRect?
    private var blurEffectView : UIVisualEffectView! // for img zoom in background
    private var zoomingImgView : UIImageView!
    private var activityIndicator: UIActivityIndicatorView!
    
    // my custom zoom in-out func: pointer from ChatMessageCell.swift;
    func performZoomInForStartingImageView(imgView: UIImageView, isVideo: Bool){
        startFrame = imgView.superview?.convert(imgView.frame, to: nil)
        //print(startFrame)
        zoomingImgView = UIImageView(frame: startFrame!)
        zoomingImgView.image = imgView.image
        zoomingImgView.isHidden = false
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
                self.zoomingImgView.frame = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
                self.zoomingImgView.center = keyWindow.center
                
                self.blurEffectView.alpha = 1
                self.inputContainerView.alpha = 0
                
            }, completion: {(finish) in
                if isVideo {
                    self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: self.view.bounds.maxX / 2 - 50, y: self.view.bounds.midY / 2 - 100, width: 100, height: 100))
                    self.activityIndicator.activityIndicatorViewStyle = .whiteLarge
                    self.activityIndicator.hidesWhenStopped = true
                    self.activityIndicator.startAnimating()
                    self.zoomingImgView.addSubview(self.activityIndicator)
                }
            })
            
        }
    }
    func performZoomOutOf() { //(tapGesture:UITapGestureRecognizer){
        //print("getting zoom out.......")
        player?.pause()
        
//        if let zoomOutView = tapGesture.view {
//        if let zoomOutView = zoomingImgView { // bcz we dont want to remove it after show, just hid it;
            zoomingImgView.layer.cornerRadius = 16
            zoomingImgView.clipsToBounds = true
            
            //UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: { // use a more smooth animation:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.zoomingImgView.frame = self.startFrame!
                self.blurEffectView.alpha = 0
                self.inputContainerView.alpha = 1

            }) { (completed: Bool) in
                self.blurEffectView.isHidden = true
                self.zoomingImgView.isHidden = true
            }
//        }
    }
    
    // for video playing zoom in to full screen:
    func playVideoFrom(url: URL) { // url comes from ChatMessageCell.swift
        
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        blurEffectView.layer.addSublayer(playerLayer)
        blurEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performZoomOutOf)))
        
        // observe player, hide image when start playing:
        player?.addObserver(self, forKeyPath: "currentItem", options: .initial, context: nil)
        player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        player?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        player?.play()
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            //print(player?.rate)
            if player?.rate == 0 { // when stop play;
                zoomingImgView.isHidden = false
            }
        }
        if keyPath == "status" { // when begin play;
            zoomingImgView.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    func didFinishPlaying() {
        performZoomOutOf()
    }
    
    
    
}
